# iris-migrations

IRIS-migrations is a database migrations tool.

IRIS-migrations allows you to create scripts for modifying a database: changing the structure, altering data, performing other data-related actions (e.g., rebuilding an index).
Each migration contains an "upgrade" script and can also contain a "downgrade" script that will be executed when rolling back the migration, reverting the database to its previous state.
Migrations are executed in a strictly defined order (based on the date of the first migration's compilation).

## Why do you need IRIS-migrations
The main purpose of IRIS-migrations is to use them in the project deployment process. Imagine you're working on a project that evolves over a long period of time. You regularly make code updates. You have the project locally, in a testing environment, pre-production, and production environments.
If you need to modify not only the code but also the data in the database (e.g., add new values to a table), you create a migration that incorporates these changes and include the execution of migrations during deployment in each environment. Therefore, as soon as your code with the migration is deployed to the corresponding environment, it will be executed.

## How to create
Create a class and specify `NSolov.Migration.AbstractMigration` as the base class.
Implement the up() method in this class and, if necessary, the down() method. These methods must return a status.

Example:

```

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

}

```

After the first compilation of the class, the DateCreate parameter will be automatically added to it.

Congratulations, you've created a migration!

In the repository https://github.com/nsolov/iris-migrations/tree/master/src/Test, you will find more examples of migrations.

## How to run

Use the methods of the `NSolov.Migrations.MigrationService` class:

`list()`: allows you to view all migrations and their status.

`migrate()`: executes all pending migrations.

`rollback()`: rolls back the last migration.

Examples:

```

USER>do ##class(NSolov.Migrations.MigrationService).list()
new : Test.FirstMigration
new : Test.TableMigration

USER>do ##class(NSolov.Migrations.MigrationService).migrate()
up : Test.FirstMigration ... done
up : Test.TableMigration ... done

USER>do ##class(NSolov.Migrations.MigrationService).list()
up : Test.FirstMigration
up : Test.TableMigration

USER>do ##class(NSolov.Migrations.MigrationService).rollback()
down : Test.TableMigration ... done

USER>do ##class(NSolov.Migrations.MigrationService).list()
up : Test.FirstMigration
down : Test.TableMigration

```

Now add the call `do ##class(NSolov.Migrations.MigrationService).migrate()` in your deployment script, so that it is invoked when new code is deployed and the database is ready.
IRIS-migrations stores information about executed migrations in the global ^migrations. This global shouldn't be deleted. If it is deleted, the migrations will be executed again.

