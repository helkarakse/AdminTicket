<?php
	/*
	 * Ticket.php\n
	 * Script for handling the data driven aspect of the ticket system\n
	 * Requires SQLite3\n
	 * @author Helkarakse (nimcuron@gmail.com)
	 * @version 1.0
	 */
	require_once("./classTicket.php");
	
	// Variables
	$ticket = new Ticket("./SQLite3Ticket.db");
	$ticket -> initDb();

	// Command parser
	if (isset($_GET["cmd"]) && $_GET["cmd"] != "") {
		$cmd = $_GET["cmd"];

		switch ($cmd) {
			case "get_tickets" :
				$array = $ticket -> getTickets();
				print_r($array);
				break;

			case "get_details" :
				$id = isset($_GET["id"]) ? $_GET["id"] : "";
				if (!empty($id)) {
					$array = $ticket -> getTicket($id);
					print_r($array);
				} else {
					echo("No id was provided.");
				}
				break;

			case "add_ticket" :
				$creator = isset($_GET["creator"]) ? $_GET["creator"] : "";
				$description = isset($_GET["description"]) ? $_GET["description"] : "";
				$position = isset($_GET["position"]) ? $_GET["position"] : "";

				if (!empty($creator) && !empty($description)) {
					$ticket -> createTicket($creator, $description, $position);
				} else {
					echo("Creator and description fields are mandatory.");
				}

				break;
		}
	}
?>