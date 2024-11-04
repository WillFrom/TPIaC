<?php
// Informations de connexion
$servername = "mysql";  // Le nom du conteneur MySQL (comme spécifié dans le réseau)
$username = "my_user";
$password = "my_password";
$database = "my_database";

// Créer une connexion
$conn = new mysqli($servername, $username, $password, $database);

// Vérifier la connexion
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Créer une table de test si elle n'existe pas
$sql = "CREATE TABLE IF NOT EXISTS test_table (id INT AUTO_INCREMENT PRIMARY KEY, data VARCHAR(255))";
if ($conn->query($sql) !== TRUE) {
    echo "Error creating table: " . $conn->error;
}

// Insertion de données de test
$sql = "INSERT INTO test_table (data) VALUES ('Hello, World!')";
if ($conn->query($sql) !== TRUE) {
    echo "Error inserting data: " . $conn->error;
}

// Lecture des données de test
$sql = "SELECT id, data FROM test_table";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // Afficher les données de chaque ligne
    while($row = $result->fetch_assoc()) {
        echo "id: " . $row["id"]. " - Data: " . $row["data"]. "<br>";
    }
} else {
    echo "0 results";
}

// Fermer la connexion
$conn->close();
?>
