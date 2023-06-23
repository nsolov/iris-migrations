Class Test.FirstMigration Extends NSolov.Migration.AbstractMigration
{

Method up() As %Status
{
    set ^x = 123
    return $$$OK
}

Method down() As %Status
{
    kill ^x
    return $$$OK
}

///  Do not change or delete this parameter
Parameter DateCreate = 1154609040750640970;

}
