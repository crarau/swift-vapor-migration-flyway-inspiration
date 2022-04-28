import Vapor

extension Application {
    func registerMigration() {
        self.migrations.add([
            CreatePerson(),
            InsertPersons(),
            CreateCompany()
        ])
    }
}

struct CreatePerson: SQLMigration {
    var file = "V1_1__Create_Person.sql"
}

struct InsertPersons: SQLMigration {
    var file = "V1_2__Insert_Persons.sql"
}


struct CreateCompany: SQLMigration {
    var file = "V1_1__Create_Person.sql"
}
