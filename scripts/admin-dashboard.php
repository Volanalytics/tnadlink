<?php
/**
 * TN Ad Link Admin Dashboard
 * This is a fallback admin dashboard that works even if the full Revive Adserver admin interface is not accessible
 */

// Detect if this is the first visit
$installed = file_exists(dirname(dirname(dirname(__FILE__))) . '/var/INSTALLED');

// System information
$phpVersion = phpversion();
$serverSoftware = $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown';
$documentRoot = $_SERVER['DOCUMENT_ROOT'] ?? 'Unknown';
$currentPath = __DIR__;
$year = date('Y');

// Check for database connection
$dbConnection = false;
$dbConnectionInfo = "Not tested";

// Try to get database info from configuration
$configFile = null;
foreach (glob(dirname(dirname(dirname(__FILE__))) . '/var/*.conf.php') as $file) {
    $configFile = $file;
    break;
}

if ($configFile) {
    // Extract DB connection info from config without executing PHP code
    $configContent = file_get_contents($configFile);
    // Simple regex to find database details - not perfect but better than eval
    preg_match('/host="([^"]+)"/', $configContent, $hostMatches);
    preg_match('/name="([^"]+)"/', $configContent, $nameMatches);
    
    $dbHost = $hostMatches[1] ?? 'Unknown';
    $dbName = $nameMatches[1] ?? 'Unknown';
    
    $dbConnectionInfo = "Host: $dbHost, Database: $dbName";
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TN Ad Link Admin Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            background-color: #0057e7;
            color: white;
            padding: 20px;
            text-align: center;
            margin-bottom: 20px;
        }
        .card {
            background-color: white;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
            padding: 20px;
        }
        h1, h2, h3 {
            margin-top: 0;
        }
        .footer {
            text-align: center;
            padding: 20px;
            color: #666;
            font-size: 0.9em;
        }
        .status {
            padding: 8px 12px;
            border-radius: 4px;
            display: inline-block;
            font-weight: bold;
        }
        .status-success {
            background-color: #d4edda;
            color: #155724;
        }
        .status-warning {
            background-color: #fff3cd;
            color: #856404;
        }
        .status-error {
            background-color: #f8d7da;
            color: #721c24;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        table, th, td {
            border: 1px solid #ddd;
        }
        th, td {
            padding: 12px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        .btn {
            display: inline-block;
            font-weight: 400;
            color: #212529;
            text-align: center;
            vertical-align: middle;
            cursor: pointer;
            background-color: transparent;
            border: 1px solid transparent;
            padding: .375rem .75rem;
            font-size: 1rem;
            line-height: 1.5;
            border-radius: .25rem;
            text-decoration: none;
            transition: color .15s ease-in-out,background-color .15s ease-in-out,border-color .15s ease-in-out;
        }
        .btn-primary {
            color: #fff;
            background-color: #0057e7;
            border-color: #0057e7;
        }
        .btn-primary:hover {
            background-color: #0046be;
            border-color: #0046be;
        }
        .btn-secondary {
            color: #fff;
            background-color: #6c757d;
            border-color: #6c757d;
        }
        .btn-secondary:hover {
            background-color: #5a6268;
            border-color: #5a6268;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>TN Ad Link Admin Dashboard</h1>
    </div>
    <div class="container">
        <div class="card">
            <h2>Welcome to TN Ad Link</h2>
            <p>This is the administration interface for TN Ad Link, Tennessee's premier advertising server platform.</p>
            
            <?php if (!$installed): ?>
            <div class="status status-warning">Installation Status: Not fully installed</div>
            <p>The TN Ad Link platform is not fully installed. Please complete the installation process.</p>
            <?php else: ?>
            <div class="status status-success">Installation Status: Installed</div>
            <p>The TN Ad Link platform is installed and running.</p>
            <?php endif; ?>
            
            <h3>Quick Links</h3>
            <a href="dashboard.php" class="btn btn-primary">Dashboard</a>
            <a href="status.php" class="btn btn-secondary">System Status</a>
            <a href="help.php" class="btn btn-secondary">Help</a>
        </div>
        
        <div class="card">
            <h2>System Information</h2>
            <table>
                <tr>
                    <th>Component</th>
                    <th>Value</th>
                </tr>
                <tr>
                    <td>PHP Version</td>
                    <td><?php echo htmlspecialchars($phpVersion); ?></td>
                </tr>
                <tr>
                    <td>Web Server</td>
                    <td><?php echo htmlspecialchars($serverSoftware); ?></td>
                </tr>
                <tr>
                    <td>Document Root</td>
                    <td><?php echo htmlspecialchars($documentRoot); ?></td>
                </tr>
                <tr>
                    <td>Current Path</td>
                    <td><?php echo htmlspecialchars($currentPath); ?></td>
                </tr>
                <tr>
                    <td>Database Connection</td>
                    <td><?php echo htmlspecialchars($dbConnectionInfo); ?></td>
                </tr>
            </table>
        </div>
        
        <div class="card">
            <h2>Next Steps</h2>
            <p>To continue setting up TN Ad Link, please:</p>
            <ol>
                <li>Verify database connection settings</li>
                <li>Set up your administrator account</li>
                <li>Configure your ad zones and placements</li>
                <li>Add advertisers and campaigns</li>
            </ol>
            <p>For more information, refer to the <a href="https://documentation.revive-adserver.com/" target="_blank">Revive Adserver documentation</a>.</p>
        </div>
    </div>
    <div class="footer">
        &copy; <?php echo $year; ?> TN Ad Link. All rights reserved.
    </div>
</body>
</html>
