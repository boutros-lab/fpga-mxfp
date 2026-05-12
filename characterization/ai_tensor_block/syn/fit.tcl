package require ::quartus::project

set PROJ_NAME [lindex $argv 0]

set PROJ_DIR [lindex $argv 1]

set REV [lindex $argv 2]

cd $PROJ_DIR

if {[project_exists $PROJ_NAME]} {
	project_open -revision $REV $PROJ_NAME 
	execute_module -tool map
	execute_module -tool fit
	execute_module -tool sta
	project_close
} else {
	error "Project does not exist."
}
