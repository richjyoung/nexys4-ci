from serial import Serial

def test_loopback():
    ser = Serial('/dev/ttyUSB1', 115200, timeout=1)
    assert ser.is_open == True

    ser.write(b'hello')
    returned = ser.read(10)
    print('Returned: %s ' % returned)
    assert returned == b'hello'

    ser.close()
    assert ser.is_open == False