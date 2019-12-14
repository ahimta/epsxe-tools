#!/usr/bin/env bash
# This is a wrapper for `snapcraft` to make it easier to develop, test, and
# release without any conflict with the local installation.
# Usage: ./scripts/snapcraft.sh <variant> [snpacraft-arg...]

# shellcheck disable=SC1091
source ./scripts/_helpers.sh

Variant=$1
Name=$(get_snap_name "$Variant")

case  $Variant  in
"debug")
  Title="ePSXe (Debug)"
  Grade="devel"
  ;;
"release")
  Title="ePSXe (Release)"
  Grade="stable"
  ;;
"store")
  Title="ePSXe"
  Grade="stable"
  ;;
"help"|"--help"|*)
  echo "Usage: ./scripts/snapcraft.sh <variant> [snpacraft-arg...]"
  exit 0
  ;;
esac

AllArgs=("$@")
RestArgs=("${AllArgs[@]:1}")
SnapcraftArgs=("${RestArgs[@]}")

SnapcraftFile=snap/snapcraft.yaml
SnapcraftTemplate=snap/local/snapcraft.scaffold.yaml

VersionMajor="2"
VersionMinor="0"
VersionPatch="5"
VersionGit=$(git rev-parse --short HEAD)
Version="$VersionMajor.$VersionMinor.$VersionPatch+git-$VersionGit"

rm --force ./*.snap
rm --force $SnapcraftFile

cp $SnapcraftTemplate $SnapcraftFile

GenerationNote="# NOTE: This file is generated using 'scripts/snapcraft.sh'."
sed --in-place "1s|^|$GenerationNote\n|" $SnapcraftFile

sed --in-place "s|@@TITLE@@|$Title|g" $SnapcraftFile
sed --in-place "s|@@NAME@@|$Name|g" $SnapcraftFile
sed --in-place "s|@@GRADE@@|$Grade|g" $SnapcraftFile
sed --in-place "s|@@VERSION@@|'$Version'|g" $SnapcraftFile

snapcraft "${SnapcraftArgs[@]}"
