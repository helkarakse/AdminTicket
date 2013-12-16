<?php
	/*
	 * Ticket.php\n
	 * Script for handling the data driven aspect of the ticket system\n
	 * Requires SQLite3\n
	 * @author Helkarakse (nimcuron@gmail.com)
	 * @version 1.0
	 */
	error_reporting(E_ALL);

	// Variables
	$dbPath = "SQLite3Ticket.db";
	$db = null;

	initDb();

	// Command parser
	if (isset($_GET["cmd"]) && $_GET["cmd"] != "") {
		$cmd = $_GET["cmd"];

		switch ($cmd) {
			case "get_tickets" :
				echo("get_tickets");
				break;

			case "get_details" :
				echo("get_details");
				break;

			case "add_ticket" :
				echo("add_ticket");
				break;
		}
	}

	// Functions
	function initDb() {
		// init the db connection
		$db = new SQLite3($dbPath) or die("Unable to create database.");
		
		// create table if not already created
		$db -> exec("CREATE TABLE IF NOT EXISTS tickets (id INTEGER PRIMARY KEY ASC, 
						creator TEXT NOT NULL, 
						description TEXT NOT NULL, 
						status INTEGER, 
						type INTEGER, 
						notes TEXT, 
						create_date DATETIME, 
						update_date DATETIME)");
	}

	function createTicket($creator, $description, $position) {

	}

	function getTickets($filter) {

	}

	function getTicket($id) {

	}
?>