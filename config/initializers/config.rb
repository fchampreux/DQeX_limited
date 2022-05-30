#Load initialisation parameters
#APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV]

### Constants
$VERSION = 'Version 1.2.4'
$AppName = 'Scheduler Prototype'

## indicators icons
# $RedThreshold = 0
$RedImage = 'red.png'
# $YellowThreshold = 60
$YellowImage = 'yellow.png'
# $GreenThreshold = 90
$GreenImage = 'green.png'
# $GreyThreshold = 0
$GreyImage = 'grey.png'

## Logo and backgrounds
#$Logo = 'oblique-4.1.1/styles/images/logo.svg'
#$Logo = 'ODQ_Flex.png'
#$Logo = 'ODQ_Logo_compact_144.png'
$Logo = 'Logo-Nr-Oakland-150x45.png'
$Splash = 'CarteSuisse2.png'
$Organisation = 'Open Data Quality'
$Organisation_URL = 'https://opendataquality.com'
$Agency = 'CH1'

## Software options
# Unicity flags the software to manage only one organisation's data
# Otherwise, the multi-tenancy mode relies on Playgrounds
$Unicity = true

# Project flags the software to manage a project hierarchy
# Otherwise, Landscapes features are hidden
$Project = false

# Assessment flags the software to display data quality indicators
# Otherwise, the indicators panes are hidden
$Assessment = false

# Version management flags the software not to manage versions of objects
# Otherwise, versions are automatically created upon edit
$Versionning = true

# Read environment proxy definition?
Faraday.ignore_env_proxy = true
