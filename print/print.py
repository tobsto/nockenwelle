#!/usr/bin/python


import math

# Abbildung der Winkel auf Papierband welches um die Welle gewickelt wird. In mm
def flatmap(angle):
	# Laenge = Pi*Durchmesser*mm/cm
	#length=math.pi*1.0*10.0
	# Tatsaechlicher Umfang in mm
	length=32
	return angle/360.0 * length
	
name='phasenwinkel_kugelwelle'
f=open('%s.txt' % name, 'r')
lines=f.readlines()
f.close()

# read in data
data=[]
for l in lines:
	wellennummer=float(l.split()[0])
	nockenposition=float(l.split()[1])
	winkel=float(l.split()[2])
	data.append([wellennummer, nockenposition, winkel])

# filter nach wellenzahl
first_column=[row[0] for row in data]
# alle wellennummern
wellennummern=list(set(first_column))
# filtere daten
data2=[]
for n in wellennummern:
	subdata=[d[1:] for d in  filter(lambda x: x[0]==n, data)]
	data2.append((n,subdata))

# schreibe latex datei
f=open('winkel.tex', 'w')
f.write("\documentclass[10pt, a4paper]{article}\n")
f.write("\\topmargin -2cm\n")
f.write("\\textheight  26cm\n")
f.write("\\begin{document}\n")
for ds in data2:
	f.write("\centerline{{\\bf Welle %i} }\n" % (int(ds[0])+1))
	f.write("\\rule{1.0\\textwidth}{0.5mm}\n")
	#f.write("\\vspace{1cm}\n")
	#f.write("\n")
	f.write("\\begin{center}\n")
	f.write("	\\begin{tabular}{c|c|c|c}\n")
	f.write("		Nockenposition & Nockenposition in cm & Winkel in Grad & Winkel in mm \\\\\n")
	f.write("		\hline\n")

	i=1
	for d in ds[1]:
		f.write("		%i & %.1f & %.1f & %.0f \\\\\n" % (i, round(d[0],1), round(d[1],1), round(flatmap(d[1]),0) ) )
		i=i+1

	f.write("	\end{tabular}\n")
	f.write("\end{center}\n")
	f.write("\\newpage\n")

f.write("\end{document}\n")
f.close()
