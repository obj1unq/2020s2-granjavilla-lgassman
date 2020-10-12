import wollok.game.*
import cultivos.*


object jardin {
	
	const plantas = #{}
	
	method agregarPlanta(planta){
		plantas.add(planta)
		game.addVisual(planta)
	}	
	
//	method regarSiHayPlanta(posicion) {
//		const regables = self.plantasEn(posicion)
//		regables.forEach({planta => planta.regar()})
//	}
	
	method regar(posicion) {
		const regables = self.plantasEn(posicion)
		if(regables.isEmpty()) {
			self.error("no tengo plantas que regar")
		}
		regables.forEach({planta => planta.regar()})
	}
	
	method regarVecinos(posicion) {
		const regables = plantas.filter({planta => self.esVecino(planta,posicion)})
		regables.forEach({planta => planta.regar()})
	}
	
	method esVecino(planta, posicion) {
		return planta.position().distance(posicion) < 2
	}
	
	method plantasEn(posicion) {
		return plantas.filter({planta => planta.position() == posicion})
	}
	
	method cosechar(recolector) {
		const cosechables = self.plantasEn(recolector.position()).filter({planta => planta.cosechable()})
		if(cosechables.isEmpty()) {
			self.error("no tengo plantas que cosechar")
		}
		cosechables.forEach({planta => self.cosecharPlanta(planta, recolector)})		
	}
	
	method cosecharPlanta(planta, recolector) {
		plantas.remove(planta)
		game.removeVisual(planta)
		recolector.agregarParaVender(planta)
	}
	
}

object hector {
	var property position = new Position(x = 3, y = 3)
	const property image = "player.png"
	
	const plantasParaVender = #{}
	var oro = 0
	
	method sembrar(planta) {
		planta.position(self.position())
		jardin.agregarPlanta(planta)
	}
	
	method regar() {
		jardin.regar(self.position())
	}
	
	method cosechar() {
		jardin.cosechar(self)
	}
	
	method agregarParaVender(planta) {
		plantasParaVender.add(planta)
	}
	
	method vender() {
		const precio = plantasParaVender.sum({planta => planta.precio()})
		const mercado = mercados.at(self.position())
		mercado.comprar(plantasParaVender, precio)
		oro += precio    
		plantasParaVender.clear()
	}
	
	method decirPosesiones() {
		game.say(self, "tengo " + oro.toString() + " monedas y " + plantasParaVender.size().toString() + " plantas para vender")
	}
	
}

object aspersor {
	
	var property position = game.at(5,5)
    const property image = "aspersor.png"
    		
 	method regar() {
		jardin.regarVecinos(self.position())
	}
	
//	method regar() {
//		(-1..1).forEach{ i => self.regarFila( position.y() + i) }
//	}
//		
//	method regarFila(fila) {
//		(-1..1).forEach{ j => self.regarPosition( position.x() + j, fila) }
//	}
//	
//	method regarPosition(x,y) {
//		jardin.regarSiHayPlanta(game.at(x,y))
//	}
	
}

object mercados {
	
	const property todos = #{}
	
 	method at(position) {
 		return todos.findOrElse({mercado => mercado.position() == position}, {self.error("No hay mercados en esta posicion") ; null})
 	}
 	
// 	method at(position) {
//		if (not todos.any({ mercado => mercado.position() == position})) {
//			self.error("No hay mercados en esta posicion")
//		}
//		return todos.find({ mercado => mercado.position() == position })
//	}
// 	
	method agregar(mercado) {
  		todos.add(mercado)
  		game.addVisual(mercado)  	
    }
 	
}

class Mercado {
	
	var property position
    const property image = "market.png"
    
    var oro
    const mercaderia = #{}
    
    method validarCompra(precio) {
    	if (oro < precio) {
    		self.error("No me alcanza el dinero")
    	}
    }
    
    method comprar(plantas, precio) {
    	self.validarCompra(precio)
    	mercaderia.addAll(plantas);
    	oro -= precio
    }
    	
}

