#!/bin/bash
. $(dirname $(readlink -f $0))/dirFunctions.sh
. $(dirname $(readlink -f $0))/svnFunctions.sh

function printDescriptionInfo()
{
  local repositorium=$1
  local revision=$2
  printf "\\nDescription info:\\nRepozytorium ${repositorium}. Rewizja: ${revision}\\n"
}

main()
{
  taxBreakMainFolder="${HOME}/TaxBreak"
  revisionToSave=$1
  formatedDate="$(date +"%Y-%m")"
  repoUrl=$(svn info 2> /dev/null | grep ^URL)
  repo=$(echo "$repoUrl" | grep -oP '(?<=svnroot/).*?(?=/)')
  branch=$(echo "$repoUrl" | grep -oP '\w+$')
  taxBreakDir="${formatedDate}-${repo}-${branch}-${revisionToSave}"
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
  printDescriptionInfo "${repoUrl}" "${revisionToSave}"
}

main "$@"
