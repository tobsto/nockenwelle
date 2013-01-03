import processing.opengl.*;

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
void nocke(float a, float b, float h, int sides)
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

// *****************
// *** Parameter ***
// *****************

// Bild
// Bildbreite
int size_x=600;
// Bildhöhe 
int size_y=600;

// Gesamtsystem (N_x Achsen, welche jeweils in z-Richtung zeigen)
// Gesamtdrehwinkel
float phi=0.0;
// Drehgeschwindigkeit
float delta_phi=0.05;
// Länge in x-Richtung
float l_x=600;
// Anzahl der Achsen
int N_x=8;
// Länge in z-Richtung
float l_z=600;
// Anzahl der Nocken pro Welle
int N_z=10;
// Gitterparamter in x-Richtung
float a_x=l_x/N_x;
// Gitterparamter in z-Richtung
float a_z=l_z/N_z;

// Welle
// Wellenlänge
float lambda=12.5*a_z;
// Winkel zwischen x-Achse und Ausbreitungsrichtung der Welle (in Radiant)
float theta=PI/2 * 0.6;
// Wellenvektor
float k_x=TWO_PI/lambda * cos(theta);
float k_z=TWO_PI/lambda * sin(theta);

// Nocke
// Abstand des Achsenmittelpunktes vom Mittelpunkt der Nocke (Ellipse)
float cam_offset=10;
// Große Halbachse der Ellipse
float cam_semi_major_axis=30;
// Kleine Halbachse der Ellipse
float cam_semi_minor_axis=30;
// Dicke der Nocke
float cam_thickness=20;
// Anzahl der Ebenen die die gekrümmte Oberfläche der Nocke bilden
int Ns_cam=50;

// Nockenwelle
// Radius der Welle
float r_shaft=10;
// Anzahl der Ebenen die die gekrümmte Oberfläche der Welle bilden
int Ns_shaft=50;

// Temporär
float psi;

void nockenwelle(int i)
{
        zylinder(r_shaft, l_z, Ns_shaft);
	translate(0,0,-l_z/2);
	// Drehung der Nocke (Anteil in z-Richtung)
	rotateZ(i*k_x*a_x);
	for (int j=0; j!=N_z-1; j++)
	{
		// Drehung der Nocke (Anteil in z-Richtung)
		psi=k_z*a_z;
		//psi=k_z*a_z;
		rotateZ(psi);

		// Position der Nocke
		translate( 0, 0, l_z/N_z);
		// Male Nocke mit versetztem Mittelpunkt
		translate(cam_offset,0,0);
        	nocke(cam_semi_major_axis, cam_semi_minor_axis, cam_thickness, Ns_cam);
		translate(-cam_offset,0,0);

	}
}

void nockenwelle_halb_verschoben(int i)
{
        zylinder(r_shaft, l_z, Ns_shaft);
	translate(0,0,-l_z/2);
	// Verschiebe um halben Gitterparameter und Rotiere demensprechend
	translate(0,0, a_z/2.0);
	rotateZ(k_z*a_z/2.0);
	// Drehung der Nocke (Anteil in z-Richtung)
	rotateZ(i*k_x*a_x);
	for (int j=0; j!=N_z-2; j++)
	{
		// Drehung der Nocke (Anteil in z-Richtung)
		psi=k_z*a_z;
		//psi=k_z*a_z;
		rotateZ(psi);

		// Position der Nocke
		translate( 0, 0, l_z/N_z);
		// Male Nocke mit versetztem Mittelpunkt
		translate(cam_offset,0,0);
        	nocke(cam_semi_major_axis, cam_semi_minor_axis, cam_thickness, Ns_cam);
		translate(-cam_offset,0,0);

	}
}
void setup()
{
	noStroke();
	size(size_x, size_y, OPENGL);
	//size(600,600,P3D);
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
		if (i%2==0)
		{
			nockenwelle(i);
		}
		else
		{
			nockenwelle_halb_verschoben(i);
		}
		popMatrix();
	}
}
