$WORK_LIB="work"
$LOG_FILE="simulation_results.txt"
$sim_path="simulation_results"
$cov_path="coverage_results"
$cov_path_txt="txt"
$cov_path_ucdb="ucdb"
# Step 1: Define the function to compile the files
function Compile-Files {
    Remove-Item -Path $WORK_LIB -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path -Path $sim_path -PathType Container) {
        Remove-Item -Path $sim_path -Recurse -Force
    }
    if (Test-Path -Path $cov_path -PathType Container) {
        Remove-Item -Path $cov_path -Recurse -Force
    }
    New-Item -ItemType Directory -Path "$sim_path"
    New-Item -ItemType Directory -Path "$cov_path"
    New-Item -ItemType Directory -Path "$cov_path\$cov_path_txt"
    New-Item -ItemType Directory -Path "$cov_path\$cov_path_ucdb"
    Write-Host "Compiling files..." 
    vlog +cover=bcesft ./Design/ALU.v
    vlog +cover=bcesft ALU_intf.sv
    vlog +cover=bcesft MyPackage.sv
    vlog +cover=bcesft Top.sv
}

function merge-ucdb {
    vsim -batch -do "
    vcover merge -64 $cov_path/$cov_path_ucdb/merge_ucdb.ucdb $cov_path/$cov_path_ucdb/*.ucdb
    vcover -details report $cov_path/$cov_path_ucdb/merge_ucdb.ucdb
    exit;"
}

# Step 2: Define the function to run a test
function Run-Test {
    param([string]$testName)
    
    $message = "Running test: $testName"
    Write-Host $message
    Add-Content -Path $sim_path\$LOG_FILE -Value $message
    
    # Create test-specific log file
    $testLogFile = "${testName}_results.txt"
    
    # Run simulation with detailed logging
    vsim -batch -voptargs="+acc" "+cover=all" "+coverdb=$cov_path\$cov_path_ucdb\${testName}.ucdb" "+UVM_NO_RELNOTES" "+UVM_REPORT_DISABLE_FILE_LINE" "+UVM_TESTNAME=$testName" work.Top -do "
        set NoQuitOnFinish 1;
        run -all
        coverage save $cov_path/$cov_path_ucdb/${testName}.ucdb;
        coverage report -output $cov_path/$cov_path_txt/${testName}_coverage_report.txt -detail -all;
        exit;" 2>&1 | Tee-Object -FilePath $sim_path\$testLogFile
    
    # Check results
    if ($LASTEXITCODE -ne 0) {
        $errorMsg = "Error during simulation for test: $testName"
        Write-Host $errorMsg -ForegroundColor Red
        Add-Content -Path $sim_path\$LOG_FILE -Value $errorMsg
        exit 1
    }
    
    # Append test-specific log to main log
    Get-Content $sim_path\$testLogFile | Add-Content $sim_path\$LOG_FILE
}


# Step 3: Compile all necessary files
Compile-Files

# Step 4: Run each of the tests sequentially
$tests = @("Initialize_Test", "Operand1_set_test", "Operand2_set1_test", "Operand2_set2_test")

foreach ($test in $tests) {
    Run-Test -testName $test
}

merge-ucdb

$completionMsg = "All tests completed successfully at $(Get-Date)"
Write-Host $completionMsg -ForegroundColor Green
Add-Content -Path $sim_path\$LOG_FILE -Value $completionMsg




#if {[string match \"*Operand2_set2_test*\" \"$testName\"]} {
#    vcover merge merged.ucdb [glob *.ucdb];
#    vcover report  $cov_path/$cov_path_ucdb/merged.ucdb > $cov_path/$cov_path_txt/merged_coverage_report.txt
#}

#vcover merge merged.ucdb [Initialize_Test.ucdb] [Operand1_set_test.ucdb] [Operand2_set1_test.ucdb] [Operand2_set2_test.ucdb]