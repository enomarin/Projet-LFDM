class pixelFloat{
  
  float[][] tab;
  
  pixelFloat(int _xSize, int _ySize) {
    tab = new float[_xSize][_ySize];
  }
  
  void addValue(float value, int _xSize, int _ySize) {
    tab[_xSize][_ySize] = value;
  }
  
  float getValue(int _xSize, int _ySize) {
    return tab[_xSize][_ySize];
  }
  
}