
"""TaskFlow - A multi-user todo app with AI meal planning."""

cl {
    import from frontend { app as ClientApp }

    def:pub app -> obj {
        return
            <ClientApp />;
    }
}

import from byllm.lib { Model }
import from uuid { uuid4 }
import from datetime { date }

glob llm = Model(model_name="ollama/llama3:latest");

# --- AI Types ---

enum Category { WORK, PERSONAL, SHOPPING, HEALTH, OTHER }

enum Unit { PIECE, LB, OZ, CUP, TBSP, TSP, CLOVE, BUNCH }

obj Ingredient {
    has name: str;
    has quantity: float;
    has unit: Unit;
    has cost: float;
    has carby: bool;
}

sem Ingredient.cost = "Estimated cost in USD";
sem Ingredient.carby = "True if this ingredient is high in carbohydrates";

"""Categorize a todo based on its title."""
def categorize(title: str) -> Category by llm();

"""Generate a shopping list of ingredients needed for a described meal."""
def generate_ingredients(meal_description: str) -> list[Ingredient] by llm();

# --- Data Nodes ---

node Todo {
    has id: str,
        title: str,
        completed: bool = False,
        category: str = "other",
        due_date: str = ""; 
}

node MealIngredient {
    has name: str,
        quantity: float,
        unit: str,
        cost: float,
        carby: bool;
}

# --- Todo Walkers ---

walker:pub AddTodo {
    has title: str,
    due_date: str = "";

    can create with `root entry {
        category = str(categorize(self.title)).split(".")[-1].lower();
        new_todo = here ++> Todo(
            id=str(uuid4()),
            title=self.title,
            category=category,
            due_date=self.due_date
        );
        report {
            "id": new_todo[0].id,
            "title": new_todo[0].title,
            "completed": new_todo[0].completed,
            "category": new_todo[0].category,
            "due_date": new_todo[0].due_date
        };
    }
}

walker:pub ListTodos {
    has todos: list = [];

    can collect with `root entry {
        visit [-->];
    }

    can gather with Todo entry {
        today = date.today().isoformat();
        is_overdue = (here.due_date != "") and (here.due_date < today) and (not here.completed);
        self.todos.append({
            "id": here.id,
            "title": here.title,
            "completed": here.completed,
            "category": here.category,
            "due_date": here.due_date
        });
    }

    can report_all with `root exit {
        report self.todos;
    }
}

walker:pub ToggleTodo {
    has todo_id: str;

    can search with `root entry {
        visit [-->];
    }

    can toggle with Todo entry {
        if here.id == self.todo_id {
            here.completed = not here.completed;
            report {
                "id": here.id,
                "completed": here.completed
            };
        }
    }
}

walker:pub DeleteTodo {
    has todo_id: str;

    can search with `root entry {
        visit [-->];
    }

    can delete with Todo entry {
        if here.id == self.todo_id {
            del here;
            report {"deleted": self.todo_id};
        }
    }
}

# --- Meal Planner Walkers ---

walker:pub GenerateShoppingList {
    has meal_description: str;

    can generate with `root entry {
        # First clear old ingredients
        visit [-->];
        # Then generate new ones
        ingredients = generate_ingredients(self.meal_description);
        result: list = [];
        for ing in ingredients {
            ing_data = {
                "name": ing.name,
                "quantity": ing.quantity,
                "unit": str(ing.unit).split(".")[-1].lower(),
                "cost": ing.cost,
                "carby": ing.carby
            };
            here ++> MealIngredient(
                name=ing_data["name"],
                quantity=ing_data["quantity"],
                unit=ing_data["unit"],
                cost=ing_data["cost"],
                carby=ing_data["carby"]
            );
            result.append(ing_data);
        }
        report result;
    }

    can clear_old with MealIngredient entry {
        del here;
    }
}

walker:pub ListMealPlan {
    has ingredients: list = [];

    can collect with `root entry {
        visit [-->];
    }

    can gather with MealIngredient entry {
        self.ingredients.append({
            "name": here.name,
            "quantity": here.quantity,
            "unit": here.unit,
            "cost": here.cost,
            "carby": here.carby
        });
    }

    can report_all with `root exit {
        report self.ingredients;
    }
}

walker:pub ClearMealPlan {
    can collect with `root entry {
        visit [-->];
    }

    can clear with MealIngredient entry {
        del here;
        report {"cleared": True};
    }
}