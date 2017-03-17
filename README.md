# DrawSketch
Draw Sketch on scratchpad in swift3(Currenlty available for iPad only).  

1. Just instantiate the object of class <b>DrawSketchViewController</b> like:

      let drawsketchVC = DrawSketchViewController(nibName: "DrawSketchViewController", bundle: nil)

2. Set <b>previosAnnotationImagePath</b>, if you are editing existing sketch.

3. Set <b>isNewSnap</b> to true, in case of new Sketch.

4. Set <b>originalImage</b>, so that white drawing screen comes when view loaded, for this we have used some function to load files from Bundle (pathForSavedImage()).

5. Set <b>image_title</b> as your image file name, name with which you want to store your sketch image.

6. Implement delegate <b>DrawSketchViewControllerDelegate</b> which will return you image path where image saved.
