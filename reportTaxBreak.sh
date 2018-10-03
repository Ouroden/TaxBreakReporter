#!/bin/bash

function ensureDirExist()
{
  local dir=$1
  mkdir -p ${dir}
}

function createDir()
{
  local dir=$1
  mkdir ${dir}
}

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

function compressDir()
{
  local compressedDirFullPath="${1}.tar.gz"
  local targetDirParentDir=$2
  local targetDirName=$3
  tar -zcf ${compressedDirFullPath} -C ${targetDirParentDir} ${targetDirName}
  sync
  printf "Generated: ${compressedDirFullPath} successfully.\\n"
}

function removeDir()
{
  local dir=$1
  rm -r ${dir}
}

function printDescriptionInfo()
{
  local repositorium=$1
  local revision=$2
  printf "\\nDescription info:\\nRepozytorium ${repositorium}. Rewizja: r${revision}\\n"
}

main()
{
  taxBreakMainFolder="${HOME}/TaxBreak"
  revisionToSave=$1
  formatedDate="$(date +"%Y-%m")"
  repoUrl=$(svn info 2> /dev/null | grep ^URL)
  repo=$(echo "$repoUrl" | grep -oP '(?<=svnroot/).*?(?=/)')
  branch=$(echo "$repoUrl" | grep -oP '\w+$')
  taxBreakDir="${formatedDate}-${repo}-${branch}-r${revisionToSave}"
  taxBreakDirFullPath="${taxBreakMainFolder}/${taxBreakDir}"
  diffFile="${taxBreakDirFullPath}/${repo}-${branch}-${revisionToSave}.diff"
  infoFile="${taxBreakDirFullPath}/${repo}-${branch}-${revisionToSave}.info"

  ensureDirExist ${taxBreakMainFolder}
  createDir ${taxBreakDirFullPath}
  createDiffFromRevision ${revisionToSave} ${diffFile}
  createInfoFromRevision ${revisionToSave} ${infoFile}
  copyChangedFilesWithHierarchyFromRevision ${revisionToSave} ${taxBreakDirFullPath}
  compressDir ${taxBreakDirFullPath} ${taxBreakMainFolder} ${taxBreakDir}
  removeDir ${taxBreakDirFullPath}

  echo "rev: ${revisionToSave}" 
  echo "repo: ${repoUrl}"
  printDescriptionInfo "${repoUrl}" "${revisionToSave}"
}

main "$@"
