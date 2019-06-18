#!/bin/bash
. $(dirname $(readlink -f $0))/dirFunctions.sh

function usage()
{
  echo ""
  echo "This tool lets you:"
  echo "    - generate TaxBreak archive"
  echo "Usage: $0  -r REVISION [-t|-z] [-a] [-m] [-v] [-h]"
  echo "Main arguments:"
  echo "    -r, --revision"
  echo "                      specify revision to process"
  echo "                      use multiple times to include multiple commits in one archive"
  echo "Compression arguments:"
  echo "    -t, --tar"
  echo "                      compress with tar, generates .tar.gz archive, default method"
  echo "    -z, --zip"
  echo "                      compress with zip, generates .zip archive"
  echo "Format and location arguments:"
  echo "    -a, --archivename"
  echo "                      specify custom archive name"
  echo "    -m, --taxbreakdir"
  echo "                      specify main TaxBreak dir, default=${HOME}/TaxBreak"
  echo "Miscellaneous arguments:"
  echo "    -v, --verbose"
  echo "                      print additional logs"
  echo "    -h, --help"
  echo "                      show this help message and exit"
}

function log_info()
{
  if [[ $verbose ]]; then printf "$1\n"; fi
}

function log_error()
{
  printf "Error: $0: $1\n"
}

function checkVersionControl()
{
  if (( $(isCurrentDirUnderSvn) )); then 
    log_info "Found SVN repository"
    . $(dirname $(readlink -f $0))/svnFunctions.sh;
  elif (( $(isCurrentDirUnderGit) )); then
    log_info "Found GIT repository"
    . $(dirname $(readlink -f $0))/gitFunctions.sh;
  else
    log_error "Directory ${PWD} is not under version control"
    exit 1
  fi
}

function parse_arguments()
{
  OPTS=$(getopt -o vhr:tza:m --long verbose,help,revision:,tar,zip,archivename:,taxbreakdir -n 'parse-options' -- "$@")
  if [ $? != 0 ] ; then log_error "Parsing options failed." >&2 ; exit 1 ; fi

  eval set -- "$OPTS"

  while true; do
    case "$1" in
      -h | --help        ) usage && exit 1 ;;
      -v | --verbose     ) verbose=1; shift ;;
      -r | --revision    ) revisionsToSave+=("$2"); shift 2 ;;
      -t | --tar         ) useTar=1; shift ;;
      -z | --zip         ) useZip=1; shift ;;
      -a | --archivename ) archiveName="$2"; shift 2 ;;
      -m | --taxbreakdir ) taxBreakMainFolder="$2"; shift 2 ;;
      -- ) shift; break ;;
      * ) break ;;
    esac
  done

  log_info "Flags:"
  log_info "verbose:${verbose}"
  log_info "revisions:${revisionsToSave[*]}"
  log_info "useTar:${useTar}"
  log_info "useZip:${useZip}"
  log_info "archivename:${archiveName}"
  log_info "taxbreakdir:${taxBreakMainFolder}\n"

  if [ -z "$revisionsToSave" ]; then
    log_error "No revision is picked."
    usage && exit 1
  fi

  if (( useTar )) && (( useZip )); then
    log_error "Pick only one compression type at the time"
    usage && exit 1
  fi

  if [ -z "$archiveName" ]; then
    currentMonth="$(date +"%Y-%m")"
    branchPrefix=$(getRepo)-$(getBranch)
    revisionsToSaveStr=$(printf ".r%s" "${revisionsToSave[@]}")
    revisionsToSaveStr=${revisionsToSaveStr:1}

    archiveName="${currentMonth}-${branchPrefix}"
    archiveNameWithRevisions="${archiveName}-${revisionsToSaveStr}"

    log_info "Using default archivename:${archiveNameWithRevisions}"
  else
    archiveNameWithRevisions=${archiveName}
  fi

  if [ -z "$taxBreakMainFolder" ]; then
    taxBreakMainFolder="${HOME}/TaxBreak"
    log_info "Using default taxbreakdir:${taxBreakMainFolder}\n"
  fi

  taxBreakDirFullPath="${taxBreakMainFolder}/${archiveNameWithRevisions}"
  targetArchiveFullPath="${taxBreakMainFolder}/${archiveNameWithRevisions}"
}

function printDescriptionInfo()
{
  local repositorium=$1
  local revision=$2
  printf "\\nDescription info:\\nRepozytorium ${repositorium}. Rewizja: ${revision}\\n"
}

function compressTaxBreakDir()
{
  if (( useZip )); then compressDirWithZip $1 $2; else compressDirWithTar $1 $2; fi
  return $?
}

main()
{
  checkVersionControl
  parse_arguments "$@"
  
  ensureDirExist ${taxBreakMainFolder}
  createDir ${taxBreakDirFullPath}

  for revisionToSave in "${revisionsToSave[@]}"; do
    printf "Saving revision: ${revisionToSave}...\n"

    diffFile="${taxBreakDirFullPath}/${archiveName}-r${revisionToSave}.diff"
    infoFile="${taxBreakDirFullPath}/${archiveName}-r${revisionToSave}.info"
    taxBreakPerRevisionDirFullPath="${taxBreakDirFullPath}/r${revisionToSave}"
    createDir ${taxBreakPerRevisionDirFullPath}

    createDiffFromRevision ${revisionToSave} ${diffFile}
    createInfoFromRevision ${revisionToSave} ${infoFile}
    copyChangedFilesWithHierarchyFromRevision ${revisionToSave} ${taxBreakPerRevisionDirFullPath}
  done

  compressTaxBreakDir ${taxBreakDirFullPath} ${targetArchiveFullPath} #|| removeDir ${taxBreakDirFullPath} && exit 1
  removeDir ${taxBreakDirFullPath}
  printDescriptionInfo "$(getRepoUrl)" "${revisionsToSave[*]}"
}

main "$@"
