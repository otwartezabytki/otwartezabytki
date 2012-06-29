# encoding: utf-8
class Tag
  def self.first_column
    {
      'mieszkalny' => 'mieszkalny',
      'gospodarczy' => 'gospodarczy',
      'sakralny' => 'sakralny',
      'militarny' => 'militarny',
      'przemysłowy' => 'przemysłowy',
      'kultury (np. teatr)' => 'kultury'
    }
  end

  def self.second_column
    {
      'edukacyjny (np. uniwersytet)' => 'edukacyjny',
      'użyteczności publicznej (np. ratusz)' => 'użyteczności_publicznej',
      'dworski/pałacowy' => 'dworski_pałacowy',
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
