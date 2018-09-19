import os
import sqlite3


class DBRecorder:
    def __init__(self, config):
        self.config = config
        self.conn = None
        self.cursor = None

    def connect_db(self):
        path = os.path.expanduser(self.config['output']['dir'])
        if not os.path.exists(path):
            os.makedirs(path)
        self.conn = sqlite3.connect(os.path.join(path, self.config['output']['file_name']))
        self.cursor = self.conn.cursor()
        if not self.conn or not self.cursor:
            print('Fail to connect to sqlite db')
            exit(-1)

    def create_db_table(self):
        if not self.conn:
            self.connect_db()
        create_strs = [
            'hash text primary key not null',
            'parent_hash text not null',
            'summary text not null',
            'description text',
            'date text',
            'author text'
        ]
        try:
            self.cursor.execute('create table record({})'.format(','.join(create_strs)))
        except sqlite3.OperationalError:
            # table already exists, do nothing
            pass

    def add_db_record(self, row):
        if not self.conn:
            self.connect_db()
        question_marks = ['?' for _ in row.keys()]
        sql_str = 'insert into record({}) values ({})'.format(','.join(row.keys()), ','.join(question_marks))
        try:
            self.cursor.execute(sql_str, tuple(row.values()))
            self.conn.commit()
        except sqlite3.DatabaseError:
            # row already exists, do nothing
            pass

    def close(self):
        self.cursor.close()
        self.conn.close()
