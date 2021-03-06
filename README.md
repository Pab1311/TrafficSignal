# Traffic Signal
This project simulates a traffic light cycle from a green light to a yellow light to a red light and repeats the cycle in an endless loop. There is a form of input as a push button to simulate a person pressing a crosswalk button to signal the system to speed up the green to red cycle so the person can walk across the street without the risk of being hit by a car. The program utilizes timers to accurately count how long each light stays on for (9 seconds for green, 3 seconds for yellow, and 6 seconds for red), with an interrupt that only affects the cycle if the green light is currently on (either turns off the green light immediately if it has already been on for 3 seconds or shortens the green timer to 3 seconds) that is called when the button is pressed. After the crosswalk cycle has ended, the traffic light cycle returns to normal until the button is pressed again.

# Circuit
![Circuit Diagram](https://github.com/Pab1311/TrafficSignal/blob/main/circuit.png)
