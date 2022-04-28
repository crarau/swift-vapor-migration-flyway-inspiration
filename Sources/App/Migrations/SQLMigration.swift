//
//  File.swift
//  
//
//  Created by Chip on 2022-04-26.
//

import Foundation
import Fluent
import SQLKit
import Vapor

protocol SQLMigration: AsyncMigration {
    var file: String { get }
}

extension SQLMigration {

    func prepare(on database: Database) async throws {
        try database.executeMigration(fileName: file)

    }

    func revert(on database: Database) async throws {
    }
}

class WiskMigrationSetup {
    static func loadMigrationsInto(_ app: Application) {
        app.databases.use(.postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432,
            username: Environment.get("DATABASE_USERNAME") ?? "postgres",
            password: Environment.get("DATABASE_PASSWORD") ?? "password",
            database: Environment.get("DATABASE_NAME") ?? "postgres"
        ), as: .psql)


        MigrationFileLoader.workingDirectory = app.directory.workingDirectory
        app.registerMigration()
    }
}

class MigrationFileLoader {
    static var workingDirectory: String!
    
    static func loadMigration(fileName: String) throws -> String {
        let directory: String = MigrationFileLoader.workingDirectory
        
        let sqlMigrationsFile = "\(directory)/Migrations/\(fileName)"
        print(sqlMigrationsFile)
        return try String(contentsOfFile: sqlMigrationsFile)
    }
}

extension Database {
    func executeMigration(fileName: String) throws {
        guard let sqlDatabase = self as? SQLDatabase else {
            throw Abort(.badRequest, reason: "Unexpected Exception")
        }

        let sqlContent = try MigrationFileLoader.loadMigration(fileName: fileName)
        
        let sqlStatements = sqlContent.split(separator: ";").map{ $0.trimmingCharacters(in: .whitespacesAndNewlines)}.filter{$0.count > 0}
        sqlStatements.forEach { sqlStatement in
            print("Executing \(sqlStatement) from file \(fileName)")
            _ = sqlDatabase.raw(SQLQueryString(sqlStatement)).all()
        }
    }
}

