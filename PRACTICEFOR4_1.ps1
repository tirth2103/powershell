# Define a relative path for the data file
$dataFilePath = ".\Employee.json"

# Check if the data file exists, if not, create an empty file
if (-not (Test-Path $dataFilePath)) {
    @() | ConvertTo-Json | Set-Content $dataFilePath
}

function Add-Employee {
  param (
      [string]$Name,
      [string]$ID,
      [string]$Department,
      [datetime]$HireDate,
      [decimal]$Salary
  )

  $employee = [PSCustomObject]@{
      Name       = $Name
      ID         = $ID
      Department = $Department
      HireDate   = $HireDate.ToString("yyyy-MM-dd")
      Salary     = $Salary
  }

  $existingData = Get-Content $dataFilePath | ConvertFrom-Json

  # Ensure $existingData is an array
  if ($existingData -eq $null) {
      $existingData = @()
  } elseif ($existingData -isnot [System.Array]) {
      $existingData = @($existingData)
  }

  $existingData += $employee
  $existingData | ConvertTo-Json -Depth 10 | Set-Content $dataFilePath
  Write-Host "Employee added successfully."
}

function Update-Employee {
    param (
        [string]$ID,
        [string]$NewDepartment,
        [datetime]$NewHireDate,
        [decimal]$NewSalary
    )

    $data = Get-Content $dataFilePath | ConvertFrom-Json

    if ($null -eq $data) {
        $data = @()
    }

    $employeeFound = $false
    for ($i = 0; $i -lt $data.Count; $i++) {
        if ($data[$i].ID -eq $ID) {
            $data[$i].Department = $NewDepartment
            $data[$i].HireDate = $NewHireDate.ToString("yyyy-MM-dd")
            $data[$i].Salary = $NewSalary
            $employeeFound = $true
            break
        }
    }

    if ($employeeFound) {
        $data | ConvertTo-Json -Depth 10 | Set-Content $dataFilePath
        Write-Host "Employee with ID: $ID updated successfully."
    } else {
        Write-Host "No employee found with ID: $ID"
    }
}

function View-Employees {
    $data = Get-Content $dataFilePath | ConvertFrom-Json
    if ($null -eq $data) {
        Write-Host "No employees found."
        return
    }
    $data | Format-Table Name, ID, Department, HireDate, Salary -AutoSize
}

function Delete-Employee {
    param (
        [string]$ID
    )

    $data = Get-Content $dataFilePath | ConvertFrom-Json

    if ($null -eq $data) {
        Write-Host "No employees found."
        return
    }

    $filteredData = $data | Where-Object { $_.ID -ne $ID }

    if ($data.Count -eq $filteredData.Count) {
        Write-Host "No employee found with ID: $ID"
    } else {
        $filteredData | ConvertTo-Json -Depth 10 | Set-Content $dataFilePath
        Write-Host "Employee with ID: $ID deleted successfully."
    }
}

# Main script logic
do {
    Write-Host "Employee Management System"
    Write-Host "1. Add Employee"
    Write-Host "2. View Employees"
    Write-Host "3. Delete Employee"
    Write-Host "4. Update Employee"
    Write-Host "5. Exit"
    $choice = Read-Host "Select an option"

    switch ($choice) {
        "1" {
            $name = Read-Host "Enter employee name"
            $id = Read-Host "Enter employee ID"
            $department = Read-Host "Enter department"
            $hireDate = Read-Host "Enter hire date (YYYY-MM-DD)"
            $salary = Read-Host "Enter salary"
            Add-Employee -Name $name -ID $id -Department $department -HireDate ([datetime]::ParseExact($hireDate, "yyyy-MM-dd", $null)) -Salary $salary
        }
        "2" {
            View-Employees
        }
        "3" {
            $id = Read-Host "Enter employee ID to delete"
            Delete-Employee -ID $id
        }
        "4" {
            $id = Read-Host "Enter employee ID to update"
            $newDepartment = Read-Host "Enter new department"
            $newHireDate = Read-Host "Enter new hire date (YYYY-MM-DD)"
            $newSalary = Read-Host "Enter new salary"
            Update-Employee -ID $id -NewDepartment $newDepartment -NewHireDate ([datetime]::ParseExact($newHireDate, "yyyy-MM-dd", $null)) -NewSalary $newSalary
            Write-Host "Employee updated successfully."
        }
        "5" {
            Write-Host "Exiting..."
            break
        }
        default {
            Write-Host "Invalid option, please try again."
        }
    }
} while ($choice -ne "5")
