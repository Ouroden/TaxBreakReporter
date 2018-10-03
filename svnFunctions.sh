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
  svn diff -c ${revision} --summarize | awk -F' ' '{ print $2 }' | xargs -I % cp -r --parents % ${outputDir}/
}

