import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8000

    WiskMigrationSetup.loadMigrationsInto(app)

    //acquire a lock
    try app.autoMigrate().wait()
    // register routes
    try routes(app)
}

