"""
This is a template you may start with for your Final Project application.
You may choose to modify it, or you may start with the example function
stubs (most of which are incomplete). An example is also posted
from Lecture 19 on Canvas.

For full credit, remove any irrelevant comments, which are included in the
template to help you get started. Replace this program overview with a
brief overview of your application as well (including your name/partners name).

Some sections are provided as recommended program breakdowns, but are optional
to keep, and you will probably want to extend them based on your application's
features.
"""
import sys  # to print error messages to sys.stderr
import mysql.connector
# To get error codes from the connector, useful for user-friendly
# error-handling
import mysql.connector.errorcode as errorcode

# Debugging flag to print errors when debugging that shouldn't be visible
# to an actual client. Set to False when done testing.
DEBUG = True


# ----------------------------------------------------------------------
# SQL Utility Functions
# ----------------------------------------------------------------------
def get_conn(user_name, password):
    """"
    Returns a connected MySQL connector instance, if connection is successful.
    If unsuccessful, exits.
    """
    try:
        conn = mysql.connector.connect(
          host='localhost',
          user=user_name,
          # SHOW VARIABLES WHERE variable_name LIKE 'port';
          port='3306',
          password=password,
          database='tennis'
        )
        print('Successfully connected.')
        return conn
    except mysql.connector.Error as err:
        # Remember that this is specific to _database_ users, not
        # application users. So is probably irrelevant to a client in your
        # simulated program. Their user information would be in a users table
        # specific to your database.
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR and DEBUG:
            sys.stderr('Incorrect username or password when connecting to DB.')
        elif err.errno == errorcode.ER_BAD_DB_ERROR and DEBUG:
            sys.stderr('Database does not exist.')
        elif DEBUG:
            sys.stderr(err)
        else:
            sys.stderr('An error occurred, please contact the administrator.')
        sys.exit(1)

# ----------------------------------------------------------------------
# Functions for Command-Line Options/Query Execution
# ----------------------------------------------------------------------
def player_match_query(firstname, lastname):
    #param1 = ''
    cursor = conn.cursor()
    # Remember to pass arguments as a tuple like so to prevent SQL
    # injection.
    temp_sql = 'SELECT firstname, lastname, tournament_name, final_score, tournament_date,\
                IF(player_id = winner_id, 1, 0) AS did_win\
                FROM player JOIN matches ON\
                (player.player_id = matches.winner_id OR player.player_id = matches.loser_id)\
                JOIN tournament ON tournament.tournament_id = matches.tournament_id \
                WHERE player.firstname LIKE \'%%%s%%\' AND player.lastname LIKE \'%%%s%%\'\
                ORDER BY tournament.tournament_date;' % (firstname, lastname, )
    try:
        cursor.execute(temp_sql)
        # row = cursor.fetchone()
        rows = cursor.fetchall()

        for row in rows:
            print(row)
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred, give something useful for clients...')


def head_to_head_query(firstname_1, lastname_1, firstname_2, lastname_2):
    #param1 = ''
    cursor = conn.cursor()
    # Remember to pass arguments as a tuple like so to prevent SQL
    # injection.
    temp_sql = 'SELECT w_player.lastname AS winner, l_player.lastname AS loser, final_score, tournament_date\
                FROM player AS w_player JOIN matches \
                ON w_player.player_id = matches.winner_id \
                JOIN player AS l_player\
                ON l_player.player_id = matches.loser_id\
                JOIN tournament\
                ON tournament.tournament_id = matches.tournament_id\
                WHERE (w_player.firstname LIKE \'%%%s%%\' AND w_player.lastname LIKE \'%%%s%%\'\
                AND l_player.firstname LIKE \'%%%s%%\' AND l_player.lastname LIKE \'%%%s%%\') OR\
                (w_player.firstname LIKE \'%%%s%%\' AND w_player.lastname LIKE \'%%%s%%\'\
                AND l_player.firstname LIKE \'%%%s%%\' AND l_player.lastname LIKE \'%%%s%%\')\
                ORDER BY tournament_date;' % (firstname_1, lastname_1, firstname_2, lastname_2, \
                firstname_2, lastname_2, firstname_1, lastname_1,)
    try:
        cursor.execute(temp_sql)
        # row = cursor.fetchone()
        rows = cursor.fetchall()

        for row in rows:
            print(row)
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred, give something useful for clients...')

def number_one_query():
    #param1 = ''
    cursor = conn.cursor()
    # Remember to pass arguments as a tuple like so to prevent SQL
    # injection.
    temp_sql = 'WITH\
                player_weeks AS\
                    (SELECT COUNT(*) AS weeks, player_id \
                    FROM ranking \
                    WHERE ranking = 1 GROUP BY player_id)\
                SELECT firstname, lastname, weeks\
                FROM player JOIN player_weeks USING (player_id)\
                ORDER BY weeks DESC;'
    try:
        cursor.execute(temp_sql)
        # row = cursor.fetchone()
        rows = cursor.fetchall()

        for row in rows:
            print(row)
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred, give something useful for clients...')

def add_new_player_py(player_id, firstname, lastname):
    #param1 = ''
    cursor = conn.cursor()
    # Remember to pass arguments as a tuple like so to prevent SQL
    # injection.
    temp_sql = 'CALL add_new_player(\'%s\', \'%s\',\'%s\');' % (player_id, firstname, lastname, )
    try:
        cursor.execute(temp_sql)
        # row = cursor.fetchone()
        rows = cursor.fetchall()

        for row in rows:
            print(row)
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred, give something useful for clients...')

# ----------------------------------------------------------------------
# Functions for Logging Users In
# ----------------------------------------------------------------------

def login():
    username = input('Enter username: ')
    password = input('Enter password: ')
        #param1 = ''
    cursor = conn.cursor()
    # Remember to pass arguments as a tuple like so to prevent SQL
    # injection.
    temp_sql = 'SELECT authenticate(\'%s\', \'%s\');' % (username, password, )
    try:
        cursor.execute(temp_sql)
        row = cursor.fetchone()
        print(row)
        if row[0] == 1:
            print('Login successful')
        else:
            print('Invalid login. Try again.')
            login()
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred, give something useful for clients...')

# ----------------------------------------------------------------------
# Command-Line Functionality
# ----------------------------------------------------------------------
def show_options():
    """
    Displays options users can choose in the application, such as
    viewing <x>, filtering results with a flag (e.g. -s to sort),
    sending a request to do <x>, etc.
    """
    print('What would you like to do? ')
    print('  (a) - find matches for a specific player')
    print('  (b) - find head to head between two players')
    print('  (c) - find all the number one players since 2000')
    print('  (d) - more nifty things!')
    print('  (q) - quit')
    print()
    ans = input('Enter an option: ').lower()
    if ans == 'q':
        quit_ui()
    elif ans == 'a':
        print('Choose your favorite player (ie. Rafael Nadal)')
        firstname = input('Enter the first name of your player: ')
        lastname = input('Enter the last name of your player: ')
        player_match_query(firstname,lastname)
    elif ans == 'b':
        print('Choose your two favorite players and see their head-to-head record')
        print('ie) Rafael Nadal and Novak Djokovic')
        firstname_1 = input('Enter the first name of your first player: ')
        lastname_1 = input('Enter the last name of your first player: ')
        firstname_2 = input('Enter the first name of your second player: ')
        lastname_2 = input('Enter the last name of your second player: ')
        head_to_head_query(firstname_1, lastname_1, firstname_2, lastname_2)
    elif ans == 'c':
        number_one_query()

        


# You may choose to support admin vs. client features in the same program, or
# separate the two as different client and admin Python programs using the same
# database.
def show_admin_options():
    """
    Displays options specific for admins, such as adding new data <x>,
    modifying <x> based on a given id, removing <x>, etc.
    """
    print('What would you like to do? ')
    print('  (a) - find matches for a specific player')
    print('  (b) - find head to head between two players')
    print('  (c) - find all the number one players since 2000')
    print('  (d) - add new player')
    print('  (q) - quit')
    print()
    ans = input('Enter an option: ').lower()
    if ans == 'q':
        quit_ui()
    elif ans == 'a':
        print('Choose your favorite player (ie. Rafael Nadal)')
        firstname = input('Enter the first name of your player: ')
        lastname = input('Enter the last name of your player: ')
        player_match_query(firstname,lastname)
    elif ans == 'b':
        print('Choose your two favorite players and see their head-to-head record')
        print('ie) Rafael Nadal and Novak Djokovic')
        firstname_1 = input('Enter the first name of your first player: ')
        lastname_1 = input('Enter the last name of your first player: ')
        firstname_2 = input('Enter the first name of your second player: ')
        lastname_2 = input('Enter the last name of your second player: ')
        head_to_head_query(firstname_1, lastname_1, firstname_2, lastname_2)
    elif ans == 'c':
        number_one_query()
    elif ans == 'd':
        player_id = input('Enter the player id: ')
        firstname = input('Enter player first name: ')
        lastname = input('Enter player last name: ')
        add_new_player_py(player_id, firstname, lastname)


def quit_ui():
    """
    Quits the program, printing a good bye message to the user.
    """
    print('Good bye!')
    exit()

def main(username):
    """
    Main function for starting things up.
    """
    login()
    while True:
        if username == 'user':
            show_options()
        else:
            show_admin_options()


if __name__ == '__main__':
    # This conn is a global object that other functinos can access.
    # You'll need to use cursor = conn.cursor() each time you are
    # about to execute a query with cursor.execute(<sqlquery>)
    username = input('Are you a manager or user: ')
    password = input('Enter your password: ')
    conn = get_conn(username, password)
    main(username)
