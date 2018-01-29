class pixelFloat{
  
  float[][] tab;
  
  pixelFloat(int _xSize, int _ySize) {
    tab = new float[_xSize+1][_ySize+1];
    for(int y = 0; y < tab[0].length; y++){
      for(int x = 0; x < tab.length; x++){
        tab[x][y] = 0.5;
      }
    }
  }
  
  void addValue(float value, PVector vector) {
    int x = floor(vector.x);
    int y = floor(vector.y);
    tab[x][y] = value;
  }
  
  float getValue(PVector vector) {
    int x = floor(vector.x);
    int y = floor(vector.y);
    return tab[x][y];
  }
  
  void printTab(){
    for(int y = 0; y < tab[0].length; y++){
      for(int x = 0; x < tab.length; x++){
        fill(map(tab[x][y],0,1,0,255));
        noStroke();
        ellipse(x,y,1,1);
      }
    }
  }
  
  
}