Class NSolov.Migration.AbstractMigration Extends %RegisteredObject [ Abstract ]
{

/// Do not set this parameter manually
///
/// Date and time of the first compilation of migration class
Parameter DateCreate;

/// Do not call this method!
/// This method sets DateCreate Parameter on first compilation
Method saveCreationDate() As %Status [ CodeMode = objectgenerator ]
{
    set paramName = "DateCreate"
    if %class.Name = "NSolov.Migration.AbstractMigration" {
        return $$$OK
    }

    set found = 0
    for i=1:1:%class.Parameters.Count() {
        set param = %class.Parameters.GetAt(i)
        if ( param.Name=paramName ) {
            if (param.Default="") {
                set param.Default = ##class(%PosixTime).CurrentUTCTimeStamp()
                do %class.%Save()
                set found = 1
                quit
            } else {
                set found = 1
            }
        }
    }

    if (found = 0) {
        // add parameter
        set newParameter = ##class(%Dictionary.ParameterDefinition).%New()
        set newParameter.Name = paramName
        set newParameter.Default = ##class(%PosixTime).CurrentUTCTimeStamp()
        set newParameter.Description = " Do not change or delete this parameter"
        do %class.Parameters.Insert(newParameter)
        do %class.%Save()
    }
    do %code.WriteLine(" Quit 1")
    return $$$OK
}

Method up() As %Status
{
    return $$$OK
}

Method down() As %Status
{
    return $$$OK
}

}
