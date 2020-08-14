# Power-Managment

Introduction:
Power consumption of the ADuC841 dependes on its internal clock frequency.
in details:internal parasitic capacities charged and discharged each clock cycle - power  wich can be saved.

Goal:
Manage the power consumption of the ADUc841 by controling the frequency of the internal clock via the keyboard.

Solution:
Controling PLLCON SFR and UART in the code (ASSEMBLY).
Taken into account  the "baud rate" depends on the actual frequency. 
Serial conunication via Putty.
