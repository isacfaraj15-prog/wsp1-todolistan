require 'debug'
require "awesome_print"

class App < Sinatra::Base
    register Sinatra::Reloader

    def db
        return @db if @db

        @db = SQLite3::Database.new(DB_PATH)
        @db.results_as_hash = true

        return @db
    end

    get '/' do
        redirect '/todos'
    end

    get '/todos' do
        @todos = db.execute("SELECT * FROM todos")
        ap @todos
        erb(:'todos/index')
    end

    get '/todos/new' do
        erb(:'todos/new')
    end

    post '/todos' do
        db.execute("INSERT INTO todos (name, description, completed) VALUES (?, ?, ?)", [params[:name], params[:description], 0])
        redirect '/todos'
    end

    get '/todos/:id' do
        @todo = db.execute("SELECT * FROM todos WHERE id = ?", params[:id]).first
        erb(:'todos/show')
    end

    post '/todos/:id/delete' do
        db.execute("DELETE FROM todos WHERE id = ?", params[:id])
        redirect '/todos'
    end

    get '/todos/:id/edit' do
        @todo = db.execute("SELECT * FROM todos WHERE id = ?", params[:id]).first
        erb(:'todos/edit')
    end

    post '/todos/:id/update' do
        completed = params[:completed] ? 1 : 0
        db.execute("UPDATE todos SET name = ?, description = ?, completed = ? WHERE id = ?", [params[:name], params[:description], completed, params[:id]])
        redirect "/todos/#{params[:id]}"
    end

    post '/todos/:id/complete' do
        db.execute("UPDATE todos SET completed = 1 WHERE id = ?", [params[:id]])
        redirect '/todos'
    end

    post '/todos/:id/incomplete' do
        db.execute("UPDATE todos SET completed = 0 WHERE id = ?", [params[:id]])
        redirect '/todos'
    end
end