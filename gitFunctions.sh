function createDiffFromRevision()
{
  local revision=$1
  local diffPath=$2
  git show ${revision} > ${diffPath}
}

function createInfoFromRevision()
{
  local revision=$1
  local infoPath=$2
  git show --name-status ${revision} > ${infoPath}
}

function copyChangedFilesWithHierarchyFromRevision()
{
  local revision=$1
  local outputDir=$2
  local oldBranchName=$(getBranch)
  git checkout ${revision} > /dev/null
  git diff-tree  --name-status --no-commit-id -r ${revision} | grep -v "^D" | awk -F' ' '{ print $2 }' | xargs -I % cp -r --parents % ${outputDir}/
  git checkout ${oldBranchName} > /dev/null
}

function getRepo()
{
  echo `git remote --v | grep origin | grep fetch | awk -F'/' '{print $(NF)}' | awk -F' ' '{print $1}'`
}

function getBranch()
{
  echo `git rev-parse --abbrev-ref HEAD`
}

function getRepoUrl()
{
  echo `git remote --v | grep origin | grep fetch | awk -F' ' '{print $2}'`
}
