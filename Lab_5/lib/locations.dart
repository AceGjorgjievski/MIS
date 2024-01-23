
import 'package:exam_schedule_google_maps/exam_schedule.dart';

class Locations {
  static Location FINKI = Location("FINKI", 42.00411, 21.40974);
  static Location FEIT = Location("FEIT", 42.00490,21.40830);
  static Location TMF = Location("TMF", 42.00470,21.41002);
  static Location MFS = Location("MFS", 42.00512,21.40837);
  static Location SHED_1 = Location("Baraka 1", 42.00454,21.40647);
  static Location SHED_2 = Location("Baraka 2", 42.00464,21.40652);
  static Location SHED_3 = Location("Baraka 3", 42.00479,21.40655);

  static List<Location> getAllLocations() {
    List<Location> allLocations = [];

    allLocations.add(FINKI);
    allLocations.add(FEIT);
    allLocations.add(TMF);
    allLocations.add(MFS);
    allLocations.add(SHED_1);
    allLocations.add(SHED_2);
    allLocations.add(SHED_3);

    return allLocations;
  }


}
