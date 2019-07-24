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
  svn info -r ${revision} > ${infoPath}
  svn diff -c ${revision} --summarize >> ${infoPath}
}

function copyChangedFilesWithHierarchyFromRevision()
{
  local revision=$1
  local outputDir=$2

  changedFiles=($(svn diff -c ${revision} --summarize | grep -v "^D" | awk -F' ' '{ print $2 }'))

  for file in "${changedFiles[@]}"; do
    outputFileDir=${outputDir}/$(dirname "${file}")
    outputFilePath=${outputDir}/"${file}"
    fileRepoPath=$(getRepoUrl)/"${file}"@${revision}

    mkdir -p ${outputFileDir}
    svn cat ${fileRepoPath} > ${outputFilePath}
  done
}

function getRepoUrl()
{
  echo $(svn info 2> /dev/null | grep ^URL | awk '{ print $2}')
}

function getRepo()
{
  echo $(getRepoUrl) | grep -oP '(?<=svnroot/).*?(?=/)'
}

function getBranch()
{
  echo $(getRepoUrl) | grep -oP '\w+$'
}
