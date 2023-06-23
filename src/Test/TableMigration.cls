Class Test.TableMigration Extends NSolov.Migration.AbstractMigration
{

Method up() As %Status
{
    &sql(CREATE TABLE SQLUser.TestTable(A %String, B %Integer))
    &sql(INSERT INTO SQLUser.TestTable(A, B) VALUES('first', 111))
    &sql(INSERT INTO SQLUser.TestTable(A, B) VALUES('second', 222))
    return $$$OK
}

Method down() As %Status
{
    &sql(DROP TABLE SQLUser.TestTable)
    return $$$OK
}

///  Do not change or delete this parameter
Parameter DateCreate = 1154609040808009830;

}
