class pixelFloat{
  
  int[][] tab;
  
  pixelFloat(int _xSize, int _ySize) {
    tab = new int[_xSize+1][_ySize+1];
  }
  
  void addValue(int value, PVector vector) {
    int x = floor(vector.x);
    int y = floor(vector.y);
    tab[x][y] = tab[x][y] + value;
  }
  
  int getValue(PVector vector) {
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