/* ----------------------------------------------------------------
Clock applet

Jump to a link on click
---------------------------------------------------------------- */

//import Needle; Permet d'importer classe si dans un autre fichier
import java.awt.Graphics;
import java.awt.Polygon;
import java.awt.Color;
import java.awt.Image;
import java.util.Date;
import java.net.URL;
import java.net.MalformedURLException;
import java.io.BufferedInputStream;
import java.util.StringTokenizer;
import java.lang.Math;


/*
This maintain a Needle (or a hand).
*/
class needle
{
  private int centerx, centery, lengthx, lengthy,width,type;
  private double angle;
  private Color color,border;
  
  /*
   * Constructs a needle.
   * @param in_color          The color
   * @param in_border         The color of the border (the border is 1 pixel wide)
   * @param in_type           The type (0=no Needle, 1=Triangle, 2=Rectangle, 3=Romb)
   * @param in_width The witdh
   * @param in_centerx The x-cord of the center
   * @param in_centery The y-cord of the center
   * @param in_lengthx The length in the x-axis
   * @param in_lengthy The lenght in the y-axis
   * @param in_angle The angle (0=To the right, pi=To the left)
  */
  public needle(Color in_color, Color in_border,int in_type,int in_width,int in_centerx, int in_centery, int in_lengthx, int in_lengthy, double in_angle)
    {
      color=in_color;                 // The color
      border=in_border;               // The color of the border (1 pixel width)
      type=in_type;                   // The type (0=no Needle, 1=Triangle, 2=Rectangle, 3=Romb)
      width=in_width;                 // The witdh
      centerx=in_centerx;             // The x-cord of the center
      centery=in_centery;             // The y-cord of the center
      lengthx=in_lengthx;             // The length in the x-axis
      lengthy=in_lengthy;             // The lenght in the y-axis
      angle=in_angle;                 // The angle (0=To the right, pi=To the left)
      
    }
  /**
   * Sets the angle of the needle.
   * @param in_angle          The needle's new angle. (0=To the right, pi/2 Up, pi=Left, 3pi/2 Down)
   */
  
  public void setAngle(double in_angle)
    {
      angle=in_angle;
    }
  /**
   * Draws the needle on a graphics object.
   * @param g         The graphics object which the needle will be drawn upon.
   */
  public void drawNeedle(Graphics g)
    {
      int x,y,dx,dy;
      double len;
      x=centerx+(int)(lengthx*Math.cos(angle));
      y=centery+(int)(lengthy*Math.sin(angle));
      len=Math.sqrt(Math.pow(x-centerx,2)+Math.pow(y-centery,2));
      dx=(int)(width*(centery-y)/len);
      dy=(int)(width*(x-centerx)/len);
      if(width==1) g.drawLine(centerx,centery,x,y);
      else 
	{
	  switch (type)
	    {
	    case 0:
	      break;
	    case 1:
	      draw_poly(centerx-dx,centerx+dx,x,x,centery-dy,centery+dy,y,y,g);
	      break;
	    case 2:
	      draw_poly(centerx-dx,centerx+dx,x+dx,x-dx,centery-dy,centery+dy,y+dy,y-dy,g);
	      break;
	    case 3:
	      draw_poly(centerx,(centerx+x)/2+dx,x,(centerx+x)/2-dx,centery,(centery+y)/2+dy,y,(centery+y)/2-dy,g);
	      break;
	    }
	} 
    }
  
  private void draw_poly(int x1,int x2,int x3,int x4,int y1,int y2,int y3,int y4,Graphics g)
    {
      int x[]={x1,x2,x3,x4,x1},y[]={y1,y2,y3,y4,y1};
      g.setColor(color);
      g.fillPolygon(x,y,5);
      g.setColor(border);
      g.drawPolygon(x,y,5);
      
    }  
}



public class clock extends java.applet.Applet implements Runnable
{
	int width,height,num_lines,sleep,timezone;
	Polygon clockBackground;
	URL homepage;
	private needle hour,minute,second;
	double pi=3.1415926535f;
	Color clockBackground_col,clockBackgroundBorder_col,backgroundBorder_col,background_col;
	Thread animate=null;
	Image backBuffer;
	Graphics backGC;
  
	public void init() // Init all the variables and classes
	{

    try {
		homepage=new URL("http://perso.wanadoo.fr/l.destailleur");
		} 
	catch (MalformedURLException e) {}

    hour=new needle(readColor(getStringAttribute("hour_col",null),Color.blue),
		    readColor(getStringAttribute("hour_border_col",null),Color.black),
		    getIntAttribute("hour_type",1,3,3),
		    getIntAttribute("hour_width",6,6,20),
		    size().width>>1,
			size().height>>1,
		    (size().width*getIntAttribute("hour_len",0,70,100))/200,
		    (size().height*getIntAttribute("hour_len",0,70,100))/200,
			0.);
    minute=new needle(readColor(getStringAttribute("minute_col",null),Color.cyan),
			readColor(getStringAttribute("minute_border_col",null),Color.black),
			getIntAttribute("minute_type",1,3,3),
			getIntAttribute("minute_width",4,4,10),
			size().width/2,
			size().height/2,
			(size().width*getIntAttribute("minute_len",0,90,100))/200,
			(size().height*getIntAttribute("minute_len",0,90,100))/200,
			0.);
    second=new needle(readColor(getStringAttribute("second_col",null),Color.lightGray),readColor(getStringAttribute("second_border_col",null),Color.black),
			getIntAttribute("second_type",0,1,3),
			getIntAttribute("second_width",0,1,5),
			size().width/2,
			size().height/2,
			(size().width*getIntAttribute("second_len",0,90,100))/200,
			(size().height*getIntAttribute("second_len",0,90,100))/200,
			0.);
      updateNeedles();
      num_lines=getIntAttribute("num_lines",3,12,1000);
      makeClockBackground();
      sleep=getIntAttribute("sleep",5,1000,20000);
      clockBackground_col=readColor(getStringAttribute("clock_background_col",null),Color.gray);
      clockBackgroundBorder_col=readColor(getStringAttribute("clock_background_border_col",null),Color.gray);
      background_col=readColor(getStringAttribute("background_col",null),Color.lightGray);
      backgroundBorder_col=readColor(getStringAttribute("background_border_col",null),Color.lightGray);
      timezone=getIntAttribute("timezone",-12,-13,12);
      resize(size().width,size().height);

	try {
		backBuffer = createImage(size().width, size().height);
		backGC = backBuffer.getGraphics();
		}
    catch (Exception e) { backGC=null; }

	}
  

	public void updateNeedles() // This updates the angle of each needle.
    {
      Date today= new Date(); // Detect time
      if (timezone!=-13)
	{
	  int hours=today.getHours();
	  int minutes=today.getMinutes();
	  hours+=timezone+today.getTimezoneOffset()/60;
	  minutes+=today.getTimezoneOffset()%60;
	  today.setMinutes(minutes);
	  today.setHours(hours);
	}
      second.setAngle(2.*pi*(today.getSeconds()-15)/60.);
      minute.setAngle(2.*pi*(today.getMinutes()-15)/60.);
      hour.setAngle(2.*pi*((today.getHours()%12-3)/12.+today.getMinutes()/720.));
    }
  
	public void paintApplet(Graphics g)  // Paint the applet 
    {
      drawClockBackground(g);
      hour.drawNeedle(g);
      minute.drawNeedle(g);
      second.drawNeedle(g);
    }      
  
  
	public void update(Graphics g) // When update is called
    {
      if (backBuffer != null)
	{ 
	  // double-buffering available
	  backGC.setColor(background_col);
	  backGC.fillRect(0,0,size().width,size().height);
	  backGC.setColor(backgroundBorder_col);
	  backGC.drawRect(0,0,size().width,size().height);
	  paintApplet(backGC);
	  g.drawImage(backBuffer, 0, 0, this);
	} else 
	  {
	    // no double-buffering
	    g.clearRect(0,0,size().width,size().height);
	    paintApplet(g);
	  }
    }

	public void run() //Run the applet
    {
      while (true) 
	{
	  updateNeedles();
	  repaint();
	  try {Thread.sleep(sleep);} catch (InterruptedException e){}
	  
	}
    }
  
	public boolean mouseEnter(java.awt.Event evt) // When the mouse enters the applet
    {
		if (timezone!=-13) {
			getAppletContext().showStatus("This clock shows GMT+"+timezone);
		}
		else {
			getAppletContext().showStatus("This clock shows GMTime");
		}
		return true;
    }
  
	public boolean mouseExit(java.awt.Event evt) // When the mouse leaves the applet
    {
      getAppletContext().showStatus("");
      return true;
    }
  
	public boolean mouseDown(java.awt.Event evt, int x,int y) // When a mouse button is pressed 
    {
      getAppletContext().showDocument(homepage);
      return true;
    }

	public void makeClockBackground() // Creates a polygon-background with num_lines-corners
    {
      double add,count;
      clockBackground=new Polygon();
      add=2.*pi/num_lines;
      for(count=0;count<=2.*pi;count+=add)
	{
	  clockBackground.addPoint(size().width/2+(int)(size().width*Math.cos(count)/2.), size().height/2+(int)(size().height*Math.sin(count)/2.));
	}
    }
      
	public void drawClockBackground(Graphics g) // Draws the background of the Clock
    {
      g.setColor(clockBackground_col);
      g.fillPolygon(clockBackground);
      g.setColor(clockBackgroundBorder_col);
      g.drawPolygon(clockBackground);
    }

	public void start()  // When the applet is started 
    {
      if (animate == null) {
	animate = new Thread(this);
	animate.start();
      }
    }
	
	public void stop() // When the applet is stopped 
    {
      if (animate != null) {
	animate.stop();
	animate=null;
      }
    }
  
  
	public Color readColor(String aColor, Color aDefault) // Creates a color from a string
    {
      if (aColor == null) { return aDefault; }
      
      int r;
      int g;
      int b;
      StringTokenizer st = new StringTokenizer(aColor, ",");
      
      try {
		r = Integer.valueOf(st.nextToken()).intValue();
		g = Integer.valueOf(st.nextToken()).intValue();
      	b = Integer.valueOf(st.nextToken()).intValue();
		return new Color(r,g,b);
      }
      catch (Exception e) {
	  	return aDefault;
      }
    }
  

	public String getStringAttribute (String att, String def)
	//************************************************************************
	// Get a string parameter 
	//************************************************************************
	{
		String ret;
      
		try {
			ret = getParameter(att);
			if (ret.length() < 1) return def;
			return ret;
	    }
		catch(Exception e) {
			return def;
		}
    }   

  
	public int getIntAttribute (String att, int min, int def, int max)
	//************************************************************************
	// Get an integer parameter 
	//************************************************************************
    {
	    try {
			int ret = Integer.parseInt(getParameter(att));
			if (ret < min) return min;
			if (ret > max) return max;
			return ret;
	    } 
		catch(Exception e) {
			return def;
	    }
	    
	} 
  
} // Fin classe clock dérivant de la classe applet



// getParameter("par") recupere valeure x de la ligne de commande HTML applet
// Ex: <applet code="applet.class"> <param name=par value=x> </applet>
// getAppletContext().showDocument("http://xxx) lance browser sur page xxx
