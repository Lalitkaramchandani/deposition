public class FollowUpTaskHelper {

    private static boolean alreadyCreatedTasks = false;


    public static boolean hasAlreadyCreatedFollowUpTasks() {
        return alreadyCreatedTasks;
    }

    public static void setAlreadyCreatedFollowUpTasks() {
        alreadyCreatedTasks = true;
    }

        }