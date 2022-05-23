-- Tables: airline, reservation, ticket, flight, passenger
-- Query: For each airline, show the client with the biggest number of tickets

SELECT airline.name, passenger.name, COUNT(ticket.id) AS total
FROM airline
JOIN reservation ON reservation.airline_id = airline.id
JOIN ticket ON ticket.reservation_id = reservation.id
JOIN flight ON flight.id = reservation.flight_id
JOIN passenger ON passenger.id = ticket.passenger_id
GROUP BY airline.name, passenger.name
ORDER BY total DESC;

