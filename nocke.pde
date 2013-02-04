import processing.opengl.*;


// *****************
// *** Parameter ***
// *****************

// Bild
// Bildbreite
int size_x=600;
// Bildhöhe 
int size_y=600;
// Frame Rate (pro Sekunde)
int fRate=10;

// *******************************************************************
// Gesamtsystem (N_x Achsen, welche jeweils in z-Richtung zeigen)
// *******************************************************************
// Gesamtdrehwinkel
float phi=0.0;
// Drehgeschwindigkeit in Umdrehungen pro Sekunde (Framerate ist 60/s) 
float delta_phi=1.0*TWO_PI/fRate;
// Länge in x-Richtung
float l_x=600;
// Anzahl der Achsen
int N_x=25;
// Länge in z-Richtung
float l_z=600;
// Anzahl der Nocken pro Welle
int N_z=100;
// Gitterparamter in x-Richtung
float a_x=l_x/N_x;
// Gitterparamter in z-Richtung
float a_z=l_z/N_z;

// *******************************************************************
// Welle (Bewegungsart)
// *******************************************************************
// Kugelwelle (true) oder Ebenewelle (false)
boolean kugelFlag=true;
// Wellenlänge
float lambda=12.5*a_z;
// Winkel zwischen x-Achse und Ausbreitungsrichtung der Welle (in Radiant)
float theta=PI/2 * 0.6;
// Kugel-Welle
// Quellenposition der Kugelwelle in x-Richtung (in Einheiten der Gitterparameter)
float r_x=N_x/2.0;
// Quellenposition der Kugelwelle in z-Richtung (in Einheiten der Gitterparameter)
float r_z=N_z/2.0;

// Abgeleitete Parameter (nicht verändern!)
// Wellenvektor (Kugelwelle)
float k=TWO_PI/lambda;
// Wellenvektor (Ebene Welle)
float k_x=TWO_PI/lambda * cos(theta);
float k_z=TWO_PI/lambda * sin(theta);

// *******************************************************************
// Nocke
// *******************************************************************
// Oberfläche offen (true) oder geschlossen (false)
boolean closedFlag=false;
// Abstand des Achsenmittelpunktes vom Mittelpunkt der Nocke (Ellipse)
float cam_offset=0.20*a_x;
// Große Halbachse der Ellipse
float cam_semi_major_axis=0.4*a_x;
// Kleine Halbachse der Ellipse
float cam_semi_minor_axis=0.4*a_x;
// Dicke der Nocke
float cam_thickness=0.3*a_z;
// Anzahl der Ebenen die die gekrümmte Oberfläche der Nocke bilden
int Ns_cam=50;

// *******************************************************************
// Nockenwelle
// *******************************************************************
// Nocken halb versetzt (true) oder nicht (false)
boolean offset=true;
// Radius der Welle
float r_shaft=0.05*a_x;
// Anzahl der Ebenen die die gekrümmte Oberfläche der Welle bilden
int Ns_shaft=50;


// ********************************************************************
// Programm (Nicht verändern)
// ********************************************************************
void zylinder(float r, float h, int sides)
{
	float phi;
	float[] x = new float[sides+1];
	float[] y = new float[sides+1];
 
	for(int i=0; i < x.length; i++)
	{
		phi = TWO_PI / (sides) * i;
		x[i] = r * cos(phi);
		y[i] = r * sin(phi);
	}
 
	//draw the top 
	beginShape(TRIANGLE_FAN);
	vertex(0, 0, h/2);
	for(int i=0; i < x.length; i++)
	{
		vertex(x[i], y[i], h/2);
	}
	endShape();
 
	//draw the outline
	beginShape(QUAD_STRIP); 
	for(int i=0; i < x.length; i++)
	{
		vertex(x[i], y[i], -h/2);
		vertex(x[i], y[i],  h/2);
	}
	endShape();
 
	//draw the bottom
	beginShape(TRIANGLE_FAN); 
	vertex(0, 0, -h/2);
	for(int i=0; i < x.length; i++)
	{
		vertex(x[i], y[i], -h/2);
	}
	endShape();
}
void nocke(float a, float b, float h, int sides, boolean closed)
{
	if (a<b)
	{
		float c=a;
		a=b;
		b=c;
	}
	// excentricity of the ellipse
	float epsilon = sqrt(a*a-b*b)/a;

	float r;
	float phi;
	float[] x = new float[sides+1];
	float[] y = new float[sides+1];
 
	for(int i=0; i < x.length; i++)
	{
		phi = TWO_PI / (sides) * i;
		r = b/sqrt(1-pow(epsilon*cos(phi), 2));
		x[i] = r * cos(phi);
		y[i] = r * sin(phi);
	}
 
	if (closed==true)
	{
		//draw the top 
		beginShape(TRIANGLE_FAN);
		vertex(0, 0, h/2);
		for(int i=0; i < x.length; i++)
		{
			vertex(x[i], y[i], h/2);
		}
		endShape();
	}
 
	//draw the outline
	beginShape(QUAD_STRIP); 
	for(int i=0; i < x.length; i++)
	{
		vertex(x[i], y[i], -h/2);
		vertex(x[i], y[i],  h/2);
	}
	endShape();
 
	if (closed==true)
	{
		//draw the bottom
		beginShape(TRIANGLE_FAN); 
		vertex(0, 0, -h/2);
		for(int i=0; i < x.length; i++)
		{
			vertex(x[i], y[i], -h/2);
		}
		endShape();
	}
}


// Temporär
float psi;

float phase_kugel_welle(float i, float j, float k, float ax, float az, float rx, float rz)
{
	return k*sqrt(pow((i-rx)*ax, 2)+pow((j-rz)*az, 2));
}
void nockenwelle_kugel(int i, boolean offset)
{
        zylinder(r_shaft, l_z, Ns_shaft);
	// Gehe zu Anfang der Welle
	translate(0,0,-l_z/2);
	// Verschiebe um halben Gitterabstand
	translate(0,0, a_z/2.0);

	// bei versetzen Nockenwellen, male eine Nocke weniger
	int NN=N_z;
	if (offset)
	{
		NN=N_z-i%2;
	}
	for (int j=0; j!=NN; j++)
	{
		// Drehung der Nocke (Anteil in z-Richtung)
		float jp = j;
		if (offset)
		{ 
			jp+=i%2*0.5;
		}
		psi=phase_kugel_welle(float(i), jp, k, a_x, a_z, r_x, r_z);
		rotateZ(psi);
		// Position der Nocke
		translate( 0, 0, jp*l_z/N_z);
		// Male Nocke mit versetztem Mittelpunkt
		translate(cam_offset,0,0);
        	nocke(cam_semi_major_axis, cam_semi_minor_axis, cam_thickness, Ns_cam, closedFlag);
		translate(-cam_offset,0,0);
		// drehe zurück
		rotateZ(-psi);
		// position zurück
		translate( 0, 0, -jp*l_z/N_z);

	}
}

float phase_ebene_welle(float i, float j, float kx, float kz, float ax, float az)
{
	return i*kx*ax + j*kz*az;
}

void nockenwelle_ebene(int i, boolean offset)
{
        zylinder(r_shaft, l_z, Ns_shaft);
	// Gehe zu Anfang der Welle
	translate(0,0,-l_z/2);
	// Verschiebe um halben Gitterabstand
	translate(0,0, a_z/2.0);

	// bei versetzen Nockenwellen, male eine Nocke weniger
	int NN=N_z;
	if (offset)
	{
		NN=N_z-i%2;
	}
	for (int j=0; j!=NN; j++)
	{
		// Drehung der Nocke (Anteil in z-Richtung)
		float jp = j;
		if (offset)
		{ 
			jp+=i%2*0.5;
		}
		psi=phase_ebene_welle(float(i), jp , k_x, k_z, a_x, a_z);
		rotateZ(psi);
		// Position der Nocke
		translate( 0, 0, jp*l_z/N_z);
		// Male Nocke mit versetztem Mittelpunkt
		translate(cam_offset,0,0);
        	nocke(cam_semi_major_axis, cam_semi_minor_axis, cam_thickness, Ns_cam, closedFlag);
		translate(-cam_offset,0,0);
		// drehe zurück
		rotateZ(-psi);
		// position zurück
		translate( 0, 0, -jp*l_z/N_z);

	}
}

void saveAnglesKugel()
{
	String dataAsString = "";
	String [] exportData = new String [N_x];
	for (int i = 0; i<N_x; i++)
	{
		dataAsString = "";
		int NN=N_z;
		if (offset)
		{
			NN=N_z-i%2;
		}
		for (int j=0; j!=NN; j++)
		{
			// Drehung der Nocke (Anteil in z-Richtung)
			float jp = j;
			if (offset)
			{ 
				jp+=i%2*0.5;
			}
			// Phasenwinkel in Grad
			float data =360.0/TWO_PI * phase_kugel_welle(float(i), jp, k, a_x, a_z, r_x, r_z) % 360;     
			dataAsString += str (data) +  "\t";
		}
		exportData [i] = dataAsString;
	}
	saveStrings ("phasenwinkel_kugelwelle.txt", exportData);
}
void saveAnglesEbene()
{
	String dataAsString = "";
	String [] exportData = new String [N_x];
	for (int i = 0; i<N_x; i++)
	{
		dataAsString = "";
		int NN=N_z;
		if (offset)
		{
			NN=N_z-i%2;
		}
		for (int j=0; j!=NN; j++)
		{
			// Drehung der Nocke (Anteil in z-Richtung)
			float jp = j;
			if (offset)
			{ 
				jp+=i%2*0.5;
			}
			// Phasenwinkel in Grad
			float data =360.0/TWO_PI * phase_ebene_welle(i, jp, k_x, k_z, a_x, a_z) % 360;     
			dataAsString += str (data) +  "\t";
		}
		exportData [i] = dataAsString;
	}
	saveStrings ("phasenwinkel_ebenewelle.txt", exportData);
}

void setup()
{
	noStroke();
	size(size_x, size_y, OPENGL);
	//size(600,600,P3D);
	frameRate(fRate);
	
	// speichere Phasenwinkel
	if (kugelFlag==true)
	{
		saveAnglesKugel();
	}
	else
	{
		saveAnglesEbene();
	}
}

void draw() 
{
	// Hintergrund schwarz
	background(0);
	// Schatten an
	lights();
	// Drehe 'Motor' weiter
	phi+=delta_phi;
	// Perspektive
	float c_h=1.0;
	float c_v=2;
	// Pespektive mit Maus verändern
	camera(c_h*width*cos(TWO_PI/width*mouseX)+width/2, c_v*mouseY-height/2, c_h*width*sin(TWO_PI/width*mouseX), width/2, height/2, 0.0, 0, 1, 0);
	// Feste Perspektive
	//camera(0,0, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);

	// Versuche
	//camera(2*mouseX-width/2, 0.0, 2*mouseY-height/2, width/2, height/2, 0, 0, 1, 0);
	//camera(mouseX, mouseY, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);
	//camera(mouseX,height/16, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);

	translate(-l_x/2,0,0);

	float axis_angle=TWO_PI/4.0;
	for (int i=0; i!=N_x; i++)
	{
		// Verschiebung in x-Richtung
		translate(l_x/N_x,0,0);
		pushMatrix();
		// Zentrieren
		translate(width/2, height/2);
		// 'Motor' Drehung
		rotateZ(phi);

		// Zeichne Nockenwelle
		// Kugelwelle
		if (kugelFlag==true)
		{
			nockenwelle_kugel(i, offset);
		}
		else
		{
			nockenwelle_ebene(i, offset);
		}
		popMatrix();
	}
}
