
[![Build Status](https://travis-ci.org/surrenderios](https://travis-ci.org/surrenderios/NSFileManager-Size.svg)


# NSFileManager-Size
An Category for NSFileManager to get file size in multi methods

* **if** read file size from extended attribute key, 
	return size
	
* **else** read file size from url attribute
	return size
	
* **else** read file size from MDItemRef
	return size
	
* **else** read file size use recursion
	return size


