Class NSolov.Migrations.MigrationService
{

/// Runs all available migrations
ClassMethod migrate(silent As %Boolean = 0) As %Status
{
    do ..getMigrations(.migrations)
    set sc = $$$OK
    set date = ""
    for {
        set date=$order(migrations(date))
        quit:date=""
        if ( ($listget(migrations(date),2) = "new") || ($listget(migrations(date),2) = "down") ) {
            try {
                tstart
                $$$ThrowOnError(..Up($listget(migrations(date),1), date))
                set message = "up : "_$listget(migrations(date),1)_" ... done"
                if 'silent {
                    write message, !
                    set sc = ..log(message)
                }
                tcommit
            } catch ex {
                trollback
                set message = "up : "_$listget(migrations(date),1)_" ... error"
                if 'silent {
                    write message, !
                    write ex.DisplayString()
                    set sc = ..log(message)
                    set sc = ..log(ex.DisplayString())
                }
                return ex
            }
        }
    }
    return sc
}

/// Rollback the previous migration
ClassMethod rollback(silent As %Boolean = 0) As %Status
{
    do ..getMigrations(.migrations)
    set date = ""
    set sc = $$$OK
    for {
        set date=$order(migrations(date),-1)
        quit:date=""
        if ($listget(migrations(date),2)="up") {
            try {
                tstart
                $$$ThrowOnError(..Down($listget(migrations(date),1), date))
                set message = "down : "_$listget(migrations(date),1)_" ... done"
                if 'silent {
                    write message, !
                    set sc = ..log(message)
                }
                tcommit
                return $$$OK
            } catch ex {
                trollback
                set message = "down : "_$listget(migrations(date),1)_" ... error"
                if 'silent {
                    write message, !
                    write ex.DisplayString()
                    set sc = ..log(message)
                    set sc = ..log(ex.DisplayString())
                }

                return ex
            }
        }
    }
    return sc
}

/// Prints all migrations with their statuses
ClassMethod list() As %Status
{
    do ..getMigrations(.migrations)
    set sc = $$$OK
    if (migrations = 0) {
        set message = "No migrations found"
        write !, message
        return sc
    }
    set date = ""
    for {
        set date=$order(migrations(date))
        quit:date=""
        set message = $listget(migrations(date),2)_" : "_$list(migrations(date),1)
        write !, message
    }
    return sc
}

ClassMethod Down(classname, date) As %Status [ Private ]
{
    set migrationObject = $classmethod(classname,"%New")
    set result = migrationObject.down()
    if $$$ISOK(result) {
        set ^migrations(date, classname) = "down"
    } else {
        set ^migrations(date, classname) = "error"
    }
    return result
}

ClassMethod Up(classname, date) As %Status [ Private ]
{
    set migrationObject = $classmethod(classname,"%New")
    set result = migrationObject.up()
    if $$$ISOK(result) {
        set ^migrations(date, classname) = "up"
    } else {
        set ^migrations(date, classname) = "error"
    }
    return result
}

ClassMethod getMigrations(Output migrations) As %Status [ Private ]
{
    set migrations = 0
    set rs = ##class(%Dictionary.ClassDefinitionQuery).SubclassOfFunc("NSolov.Migration.AbstractMigration")
    while rs.%Next() {
        set class = ##class(%Dictionary.ClassDefinition).%OpenId(rs.Name)
        set date = ""
        for i=1:1:class.Parameters.Count() {
            set param = class.Parameters.GetAt(i)
            if ( param.Name = "DateCreate" ) {
                set date = ##class(%PosixTime).LogicalToTimeStamp(param.Default)
            }
        }
        if (date '= "") {
            set migrations(date) = $listbuild(rs.Name, $get(^migrations(date, rs.Name),"new"))
            do $increment(migrations)
        }
    }
}

ClassMethod log(message As %String) As %Status [ Private ]
{
  return ##class(%SYS.System).WriteToConsoleLog(message,, 0)
}

}