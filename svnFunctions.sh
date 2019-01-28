function createDiffFromRevision()
{
  local revision=$1
  local diffPath=$2
  svn diff -c ${revision} > ${diffPath}
}

function createInfoFromRevision()
{
  local revision=$1
  local infoPath=$2
  svn info -r ${revision} > ${infoFile}
  svn diff -c ${revision} --summarize >> ${infoFile}
}

function copyChangedFilesWithHierarchyFromRevision()
{
  local revision=$1
  local outputDir=$2
  svn diff -c ${revision} --summarize | grep -v "^D" | awk -F' ' '{ print $2 }' | xargs -I % cp -r --parents % ${outputDir}/
}

function getRepoUrl()
{
  echo $(svn info 2> /dev/null | grep ^URL)
}

function getRepo()
{
  echo $(getRepoUrl) | grep -oP '(?<=svnroot/).*?(?=/)'
}

function getBranch()
{
  echo $(getRepoUrl) | grep -oP '\w+$'
}
