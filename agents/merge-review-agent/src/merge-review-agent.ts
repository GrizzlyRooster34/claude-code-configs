import 'dotenv/config';
import { Octokit } from '@octokit/rest';
import { graphql } from '@octokit/graphql';

const GH_TOKEN = process.env.GH_TOKEN!;
const OWNER = process.env.OWNER!;
const REPO = process.env.REPO!;
const BASE = process.env.BASE || 'merge-review';
const MAIN = process.env.MAIN || 'main';

if (!GH_TOKEN) {
  console.error('Missing GH_TOKEN in .env'); process.exit(1);
}

const octokit = new Octokit({ auth: GH_TOKEN });
const gql = graphql.defaults({
  headers: { authorization: `token ${GH_TOKEN}` }
});

async function ensureBaseBranch() {
  // check if BASE exists
  try {
    await octokit.repos.getBranch({ owner: OWNER, repo: REPO, branch: BASE });
    return;
  } catch (_) {}
  // get MAIN sha
  const mainRef = await octokit.git.getRef({ owner: OWNER, repo: REPO, ref: `heads/${MAIN}` });
  const sha = mainRef.data.object.sha;
  await octokit.git.createRef({ owner: OWNER, repo: REPO, ref: `refs/heads/${BASE}`, sha });
  console.log(`[init] created ${BASE} from ${MAIN} @ ${sha}`);
}

async function listBranches(): Promise<string[]> {
  const out: string[] = [];
  let page = 1;
  for (;;) {
    const res = await octokit.repos.listBranches({ owner: OWNER, repo: REPO, per_page: 100, page });
    if (res.data.length === 0) break;
    for (const b of res.data) {
      const name = b.name;
      if (name !== MAIN && name !== BASE) out.push(name);
    }
    page++;
  }
  return out;
}

async function findOrCreatePR(head: string): Promise<{number: number, nodeId: string}> {
  // try find existing open PR head->BASE
  const prs = await octokit.pulls.list({
    owner: OWNER, repo: REPO, state: 'open', base: BASE, head: `${OWNER}:${head}`, per_page: 100
  });
  if (prs.data.length) {
    const pr = prs.data[0];
    return { number: pr.number, nodeId: pr.node_id! };
  }
  const pr = await octokit.pulls.create({
    owner: OWNER, repo: REPO,
    title: `Merge-review: ${head} → ${BASE}`,
    head, base: BASE,
    body: 'Automated PR to stage branch into merge-review for CI & conflict surfacing.'
  });
  return { number: pr.data.number, nodeId: pr.data.node_id! };
}

async function enableAutoMerge(prNodeId: string) {
  // GraphQL: enable auto-merge (SQUASH)
  const mutation = `
    mutation EnableAutoMerge($pr:ID!) {
      enablePullRequestAutoMerge(input:{
        pullRequestId:$pr, mergeMethod:SQUASH
      }) { clientMutationId }
    }
  `;
  try {
    await gql(mutation, { pr: prNodeId });
    console.log(`[auto-merge] enabled`);
  } catch (e:any) {
    const msg = e?.errors?.[0]?.message || e.message || String(e);
    // not fatal (might be blocked by branch protection / missing perms)
    console.warn(`[auto-merge] could not enable: ${msg}`);
  }
}

async function run() {
  console.log(`[agent] ${OWNER}/${REPO} → base=${BASE}, main=${MAIN}`);
  await ensureBaseBranch();
  const branches = await listBranches();
  console.log(`[scan] found ${branches.length} candidate branches`);
  let created = 0;

  for (const head of branches) {
    try {
      const { number, nodeId } = await findOrCreatePR(head);
      console.log(`[pr] #${number} ${head} → ${BASE}`);
      await enableAutoMerge(nodeId);
      created++;
    } catch (e:any) {
      console.error(`[error] ${head}: ${e?.message || e}`);
    }
  }
  console.log(`[done] processed=${branches.length} opened/updated=${created}`);
}

run().catch(e => { console.error(e); process.exit(1); });
