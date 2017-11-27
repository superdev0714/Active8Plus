
#ifndef _CHROMAGIC_H_
#define _CHROMAGIC_H_

/*! \file Chromagic.h
    \breif A documented file
 
    Details.
 */

/*! A Chromagic namespace */
namespace Chromagic
{
	// The main chroma key class.
	class IChromaKey
	{
	public:
        
        /** Constructor and Destructors.
         *  These functions are constructors and destructors.
         */
		IChromaKey()				{}
		virtual ~IChromaKey()		{}
		
        /** \fn void chroma(int width, int height, unsigned char *rgba)
		 *  \brief Given an rgba block of data, this function adjusts the alpha in place to achieve the keying.
		 */
        virtual void chroma(int width, int height, unsigned char *rgba) = 0;
		
        /** \fn void setHue(float hue)
         *  \brief This function sets the hue value
         *
         *  Details.
         *  The Value of the Hue to center the chroma key around.  This should be a value between
		 *  0.0f and 360.0f representing the degrees, where 0.0 is Red, 120.0 is Green, and 240.0 is Blue.
		 *  The default is 120.0.
         */
		virtual void setHue(float hue) = 0;
        
        /** \fn float hue()
         *  \brief This function get the hue value
         */
		virtual float hue() = 0;
		
        /** \fn void setTolerance(float tolerance)
         * \brief This function sets the tolerance value.
         * 
         * Details.
		 * Value in degrees the chroma key will vary.  This effectively increases the pie slice in
		 * HSV color space to chroma out.
		 * The default is 30.0.
         */
		virtual void setTolerance(float tolerance) = 0;
        
        /** \fn float tolerance()
         *  \brief This function gets the tolerance value.
         *
         */
		virtual float tolerance() = 0;
		
        /** \fn void setSaturation(float saturation)
         *  \brief This function sets the saturation value.
         *
         * Details.
		 * The minimum saturation to begin chroma keying out.  This value is normalized between 0.0 and 1.0.
		 * The default is 0.2.
         */
		virtual void setSaturation(float saturation) = 0;
        
        /** \fn float saturation()
         *  \brief This function gets the saturation value.
         */
		virtual float saturation() = 0;
		
        /** \fn void setValue(float min, float max)
         *  \brief This function sets the minimum and maximum saturation values.
         *
         * Details.
		 * Determines the min and maxmimum saturation to be excluded.  The min saturation is used to exclude
		 * shadows from being chroma keyed out, and the max to keep whites from being chroma keyed out.
		 * The default values are 0.35 and 0.95
         */
		virtual void setValue(float min, float max) = 0;
        
        /** \fn float minValue()
         *  \brief This function gets minimum value.
         */
		virtual float minValue() = 0;
        
        /** \fn float maxValue()
         *  \brief This function gets maximum value.
         */
		virtual float maxValue() = 0;
		
        /** \fn void setSpill(float left, float right)
         *  \brief This function sets the left and right values.
         *
         * Details.
		 * The number of pixels to adjust for chroma spill on the left and right sides of the foreground.
		 * The default is 2.0 and 2.0.
         */
		virtual void setSpill(float left, float right) = 0;
        
        /** \fn float leftSpill()
         *  \brief This function gets the left value.
         */
		virtual float leftSpill() = 0;
        
        /** \fn float rightSpill()
         *  \brief This function gets the right value
         */
		virtual float rightSpill() = 0;
	};	
	
    /** \fn IChromaKey* createChromaKey()
     *  \brief This function generates the chroma key.
     */
	IChromaKey *createChromaKey();
    
    /** \fn void destroyChromaKey(IChromaKey *key)
     *  \brief This function destroys the chroma key.
     */
	void destroyChromaKey(IChromaKey *key);
	
}

#endif
