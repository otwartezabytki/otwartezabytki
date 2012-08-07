# encoding: utf-8
class Category
  def self.first_column
    {
      'mieszkalny' => 'mieszkalny',
      'gospodarczy' => 'gospodarczy',
      'sakralny' => 'sakralny',
      'militarny' => 'militarny',
      'przemysłowy' => 'przemysłowy',
      'kultury' => 'kultury (np. teatr)'
    }
  end

  def self.second_column
    {
      'edukacyjny' => 'edukacyjny (np. uniwersytet)',
      'użyteczności_publicznej' => 'użyteczności publicznej (np. ratusz)',
      'dworski_pałacowy' => 'dworski/pałacowy',
      'cmentarny' => 'cmentarny',
      'przyrodniczy' => 'przyrodniczy',
      'miejski' => 'miejski'
    }
  end

  def self.third_column
    {
      'katolicki' => 'katolicki',
      'prawosławny' => 'prawosławny',
      'protestancki' => 'protestancki',
      'żydowski' => 'żydowski',
      'muzułmański' => 'muzułmański',
      'łemkowski' => 'łemkowski',
      'unicki' => 'unicki',
      'inny' => 'inny'
    }
  end

  def self.all
    @all ||= first_column.merge(second_column).merge(third_column)
  end
end
