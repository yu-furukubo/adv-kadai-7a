# frozen_string_literal: true

class BooksController < ApplicationController
  before_action :ensure_correct_user, only: [:update, :edit, :destroy]

  def show
    @book = Book.find(params[:id])
    unless VisitCount.where(created_at: Time.zone.now.all_day).find_by(user_id: current_user.id, book_id: @book.id)
      current_user.visit_counts.create(book_id: @book.id)
    end
    @books = Book.all
    @book_new = Book.new
    @book_comment = BookComment.new

  end

  def index
    from = (Time.current - 6.day).at_beginning_of_day
    to = Time.current
    @books = Book.includes(:favorites).sort_by{ |book| -book.favorites.where(created_at: from..to).count }
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      render "index"
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end

  private
    def book_params
      params.require(:book).permit(:title, :body, :user_id)
    end

    def ensure_correct_user
      @book = Book.find(params[:id])
      unless @book.user_id == current_user.id
        redirect_to books_path
      end
    end

end
