

##
# Functions
##

##
# Parse a "Power Scheme" line of powercfg output
##
function parsePowerConfigListLine ($line) {
    # for pure return value, wrap all work in null-assigned self-executing script block
    $null = .{

        # [hashtable]$return = @{}
        $return = @{}

        if ($line -match "^Power Scheme") {

            $line | select-string -Pattern "GUID: (?<guid>[^\s]+)\s+\((?<name>.*)\)" | select -expand Matches | foreach {
                if (! $guid) {
                    $guid = $_.groups["guid"].value
                    $name = $_.groups["name"].value
                }
            }

            $return."guid" = $guid
            $return."name" = $name
        }
    }

    Return $return
}

##
# Main Script
##

$askscheme = $args[0]

if (! $askscheme) {
    echo "Please provide scheme argument"
    exit 1
}


$match


$out = powercfg -list


foreach ($line in $out) {
    $match_i = parsePowerConfigListLine $line
    if ($match_i."name" -imatch $askscheme) {
        $match = $match_i
        break
    }
}


$name = $match."name"
$guid = $match."guid"


if (! $guid) {
    echo "No match."
    exit 1
}


echo "Setting power plan ""${name}"" ($guid)"

powercfg -setactive $guid

$activeSchemeLine = powercfg -GETACTIVESCHEME

$activeScheme = parsePowerConfigListLine $activeSchemeLine
$activeName = $activeScheme."name"
$activeGuid = $activeScheme."guid"

echo "Active scheme: ${activeName} (${activeGuid})"
