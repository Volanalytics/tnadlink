<?php
/**
 * Script to create the schema in the Supabase database
 */

// Get database connection details from environment variables
$host = getenv('SUPABASE_DB_HOST');
$port = getenv('SUPABASE_DB_PORT') ?: '5432';
$user = getenv('SUPABASE_DB_USER');
$pass = getenv('SUPABASE_DB_PASSWORD');
$dbname = getenv('SUPABASE_DB_NAME');
$schema = getenv('SUPABASE_DB_SCHEMA') ?: 'tnadlink';

echo "Creating schema '$schema' if it doesn't exist...\n";

try {
    // Connect to the database
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname;";
    $conn = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
    
    // Check if schema exists
    $stmt = $conn->prepare("SELECT schema_name FROM information_schema.schemata WHERE schema_name = :schema");
    $stmt->bindParam(':schema', $schema);
    $stmt->execute();
    
    if (!$stmt->fetch()) {
        // Create schema if it doesn't exist
        $conn->exec("CREATE SCHEMA $schema");
        echo "Schema '$schema' created successfully.\n";
        
        // Set the search path for future operations
        $conn->exec("SET search_path TO $schema, public");
        
        // Create extension if needed
        $conn->exec("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\" WITH SCHEMA $schema");
    } else {
        echo "Schema '$schema' already exists.\n";
    }
    
    // Set the schema as default for the database user
    $conn->exec("ALTER ROLE \"$user\" SET search_path TO $schema, public");
    
    echo "Schema configuration completed successfully.\n";
    exit(0);
    
} catch (PDOException $e) {
    echo "Database error: " . $e->getMessage() . "\n";
    exit(1);
}
?>
