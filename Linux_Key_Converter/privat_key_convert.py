from Crypto.PublicKey import RSA
import base64
import xml.etree.ElementTree as ET

def get_value(xml, tag):
    return int.from_bytes(base64.b64decode(xml.find(tag).text), byteorder='big')

with open("private_key.xml", "r") as f:
    xml = ET.fromstring(f.read())

modulus = get_value(xml, "Modulus")
exponent = get_value(xml, "Exponent")
d = get_value(xml, "D")
p = get_value(xml, "P")
q = get_value(xml, "Q")
dp = get_value(xml, "DP")
dq = get_value(xml, "DQ")
iq = get_value(xml, "InverseQ")

key = RSA.construct((modulus, exponent, d, p, q))
pem = key.export_key()

with open("private_key.pem", "wb") as f:
    f.write(pem)
print("[✔] PEM private key saved as private_key.pem")
