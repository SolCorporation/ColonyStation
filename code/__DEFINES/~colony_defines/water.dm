#define EQUALIZE_WATER_TEMP(m1, t1, m2, t2) (m1 * t1 + m2 * t2) / (m1+m2)
///How much water does a waternet get, also determines how much the water meters show, with this amount being 1
#define STARTING_WATER_AMOUNT 200
///Minimum temperature of water coming out of the cooling tower / heat exchanger
#define MINIMUM_WATER_TEMP 274
