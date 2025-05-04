<?php
/**
 * Script to wait for database connection
 * Used during deployment to ensure database is ready before continuing
 */

// Get database connection details from environment variables
$host = getenv('SUPABASE_DB_HOST');
$port = getenv('SUPABASE_DB_PORT') ?: '5432';
$user = getenv('SUPABASE_DB_USER');
$pass = getenv('SUPABASE_DB_PASSWORD');
$dbname = getenv('SUPABASE_DB_NAME');

echo "Waiting for PostgreSQL connection...\n";

// Set maximum number of attempts
$max_attempts = 30;
$attempt = 0;
$connected = false;

while (!$connected && $attempt < $max_attempts) {
    $attempt++;
    echo "Attempt $attempt of $max_attempts...\n";
    
    try {
        // Try to connect to the database
        $dsn = "pgsql:host=$host;port=$port;dbname=$dbname;";
        $conn = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_TIMEOUT => 5
        ]);
        
        // Test connection with a simple query
        $conn->query("SELECT 1");
        $connected = true;
        echo "Successfully connected to the database.\n";
    } catch (PDOException $e) {
        echo "Connection failed: " . $e->getMessage() . "\n";
        
        if ($attempt < $max_attempts) {
            echo "Retrying in 5 seconds...\n";
            sleep(5);
        } else {
            echo "Maximum attempts reached. Could not connect to the database.\n";
            exit(1);
        }
    }
}

if ($connected) {
    exit(0);
} else {
    exit(1);
}
?>
